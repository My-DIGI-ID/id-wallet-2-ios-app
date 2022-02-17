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

// This implementation is just a stub serving as placeholder until we
// have a backend. I would use a to-do marker, but that would make
// swiftlint unhappy.
class Authenticator {
    enum AuthenticationState {
        case authenticated(authenticationTime: Date)
        case authenticationExpired(authenticationTime: Date)
        case authenticationFailed(authenticationTime: Date)
        case unauthenticated
        case uninitialized
    }
    
    init() {

    }
    
    // Queries the state and expires the authentication if necessary
    func authenticationState() -> AuthenticationState {
        return IDWalletSecurity.shared().isInitialized() ? .unauthenticated : .uninitialized
    }
    
    // Sets the specified pin if no pin is defined
    func definePIN(pin: String) async {
        do {
            let walletKey = try await IDWalletSecurity.shared().save(pin: pin)
            try await CustomAgentService().setup(with: walletKey)
            print("AGENT SETUP SUCCESSFUL")
        } catch {
            print("AGENT SETUP FAILED: \(error)")
        }
    }
    
    func authenticate(pin: String) async -> AuthenticationState {
        do {
            let storedPassword = try IDWalletSecurity.shared().getStoredPassword()
            guard pin.validate(with: storedPassword) else {
                return .authenticationFailed(authenticationTime: Date())
            }
            let walletKey = try IDWalletSecurity.shared().getWalletKey(for: pin)
            try await Aries.agent.open(with: "ID", walletKey)
            return .authenticated(authenticationTime: Date())
        } catch {
            print(error)
            return .authenticationFailed(authenticationTime: Date())
        }
    }
    
    func reset() {

    }
}
