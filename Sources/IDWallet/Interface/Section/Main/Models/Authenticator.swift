//
//  Authenticator.swift
//  IDWallet
//
//  Created by Michael Utech on 16.12.21.
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

  init() {
    pin = nil
    state = .uninitialized
  }

  private let maxAge: TimeInterval = 60.0 * 30.0
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

    self.pin = pin
    self.state = .authenticated(authenticationTime: Date())
  }

  func authenticate(pin: String) async -> AuthenticationState {
    state =
      (pin == self.pin
        ? .authenticated(authenticationTime: Date())
        : .authenticationFailed(authenticationTime: Date()))
    return state
  }

  func reset() {
    state = .uninitialized
    pin = nil
  }
}
