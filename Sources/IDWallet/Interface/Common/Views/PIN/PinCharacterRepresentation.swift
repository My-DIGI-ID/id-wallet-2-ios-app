//
//  PinCharacterRepresentation.swift
//  IDWallet
//
//  Created by Michael Utech on 07.12.21.
//

import Foundation

///
/// Represents a single pin code character for use by the UI
///
enum PinCharacterRepresentation: Equatable {
  /// Placeholder for a PIN character that has not yet been set
  case unset

  /// Placeholder for the next PIN character (will be set on next character entry)
  case unsetActive

  /// Placeholder for an optional PIN character that has not yet been set
  case unsetOptional

  /// Placeholder for the next optional PIN character (will be set on next character entry)
  case unsetOptionalActive

  /// PIN character that is hidden (f.e. to be displayed as "*")*
  case setHidden

  /// PIN character that is visible to the user (usually the last entered character)
  /// A presentation can chose to ignore the clear text and display this the same as `.setHidden`
  case set(character: String)
}
