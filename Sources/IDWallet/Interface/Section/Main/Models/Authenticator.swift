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
    
    // the pin should obviously not be stored here but instead queried from
    // secured storage
    private var pin: String?
    
    private var state: AuthenticationState
    
    private let maxAge: TimeInterval = 60.0 * 30.0
    
    init() {
        pin = nil
        state = .uninitialized
    }
    
    // Queries the state and expires the authentication if necessary
    func authenticationState() async -> AuthenticationState {
        switch state {
        case .authenticated(let authenticationTime):
            let age: TimeInterval = Date().timeIntervalSince(authenticationTime)
            if age > maxAge {
                state = .authenticationExpired(authenticationTime: authenticationTime)
            }
            return state
        default:
            return state
        }
    }
    
    // Sets the specified pin if no pin is defined
    func definePIN(pin: String) async {
        guard self.pin == nil else {
            ContractError.guardAssertionFailed("Attempt to define PIN even though it is already defined.")
                .fatal()
        }
        do {
            let walletKey = try await IDWalletSecurity.shared().save(pin: pin)
            state = .authenticated(authenticationTime: Date())
            self.pin = pin
        } catch {
            state = .uninitialized
        }

    }
    
    func authenticate(pin: String) async -> AuthenticationState {
        state = (
            pin == self.pin ?
                .authenticated(
                    authenticationTime: Date()) :
                    .authenticationFailed(
                        authenticationTime: Date()))
        return state
    }
    
    func reset() {
        state = .uninitialized
        pin = nil
    }
}
