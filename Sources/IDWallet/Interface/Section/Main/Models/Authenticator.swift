//
// Copyright 2022 Bundesrepublik Deutschland
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
import Foundation
import Aries
import CocoaLumberjackSwift

class Authenticator {
    enum AuthenticationState {
        case authenticated(authenticationTime: Date)
        case authenticationExpired(authenticationTime: Date)
        case authenticationFailed(authenticationTime: Date)
        case authenticationError(error: Error)
        case unauthenticated
        case uninitialized
    }

    // Queries the state
    func authenticationState() async -> AuthenticationState {
        let security = IDWalletSecurity.shared()
        guard security.isInitialized() else {
            return .uninitialized
        }

        do {
            // If App has been uninstalled, keychain entries will remain.
            let walletKey = try IDWalletSecurity.shared().getWalletKey(for: "000000") // Any pin will do
            try await Aries.agent.open(with: "ID", walletKey)
            try await Aries.agent.close()
        } catch let error where "\(error)" == "walletNotFound" {
            // this means there is no DB, delete keychain entries
            try? security.reset()
            return .uninitialized
        } catch {
            print("\(error)")
            // The PIN we used above is likely not the real thing, so we expect this error here
        }

        // authentication state is never authenticated
        return .unauthenticated
    }
    
    // Sets the specified pin if no pin is defined
    func definePIN(pin: String) async {
        do {
            let walletKey = try await IDWalletSecurity.shared().save(pin: pin)
            guard IDWalletSecurity.shared().isInitialized() else {
                fatalError("definedPIN: IDWalletSecurity.save(pin:) failed to save PIN")
            }
            let other = try IDWalletSecurity.shared().getWalletKey(for: pin)
            guard other == walletKey else {
                fatalError("definePIN: Wallet key mismatch: \(walletKey) != \(other)")
            }
            try await CustomAgentService().setup(with: walletKey)
            DDLogDebug("definePIN: AGENT SETUP SUCCESSFUL")
        } catch {
            DDLogError("definePIN: AGENT SETUP FAILED: \(error)")
            do {
                try IDWalletSecurity.shared().reset()
            } catch {
                DDLogError("definePIN: Failed to reset keychain entries: \(error)")
            }
        }
    }

    func reset() async throws {
        try IDWalletSecurity.shared().reset()
    }

    func authenticate(pin: String) async -> AuthenticationState {
        do {
            let storedPassword = try IDWalletSecurity.shared().getStoredPassword()
            guard pin.validate(with: storedPassword) else {
                return .authenticationFailed(authenticationTime: Date())
            }
            let walletKey = try IDWalletSecurity.shared().getWalletKey(for: pin)
            do {
                try await Aries.agent.open(with: "ID", walletKey)
                return .authenticated(authenticationTime: Date())
            } catch let error where error.localizedDescription == "walletNotFound" {
                return .uninitialized
            } catch {
                return .authenticationFailed(authenticationTime: Date())
            }
        } catch let error {
            let x = error
            DDLogError("authenticate: failed: \(x)")
            return .authenticationError(error: error)
        }
    }
}
