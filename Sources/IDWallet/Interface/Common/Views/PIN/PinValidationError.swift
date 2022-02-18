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

enum PinValidationError: Error, ValidationError {
    /// Contract violation, UI is supposed to prevent this
    /// - Parameter actual: actual length
    /// - Parameter expected: expected minimum length
    case tooShort(actual: UInt, expected: UInt)
    
    /// Contract violation, UI is supposed to prevent this
    /// - Parameter actual: actual length
    /// - Parameter expected: expected length
    case tooLong(actual: UInt, expected: UInt)
    
    /// Contract violation, UI is supposed to prevent this
    /// - Parameter expected: description of complexity rules
    case tooSimple(expected: String)
    
    /// Contract violation, UI is supposed to prevent this
    /// - Parameter actual: invalid PIN character
    /// - Parameter expected: Description of valid PIN characters
    case invalidPinCharacter(actual: String, expected: String = "0-9")
    
    /// User failed to enter the same PIN
    case confirmationMismatch
    
    var title: String { NSLocalizedString("PIN validation error", comment: "error type title") }
    
    var problem: String {
        switch self {
        case .tooLong:
            return NSLocalizedString("PIN too long", comment: "error problem phrase")
        case .tooShort:
            return NSLocalizedString("PIN too short", comment: "error problem phrase")
        case .tooSimple:
            return NSLocalizedString("PIN is not sufficiently complex", comment: "error problem phrase")
        case .invalidPinCharacter:
            return NSLocalizedString("PIN contains invalid character(s)", comment: "error problem phrase")
        case .confirmationMismatch:
            return NSLocalizedString(
                "Confirmation PIN does not match original", comment: "error problem phrase")
        }
    }
    
    var expectation: String? {
        switch self {
        case .tooLong(_, let expected):
            return String.localizedStringWithFormat(
                NSLocalizedString(
                    "expected up to %d characters",
                    comment: "error expectation: maximum lenght(max # characters)"), expected)
            
        case .tooShort(_, let expected):
            return String.localizedStringWithFormat(
                NSLocalizedString(
                    "expected at least %d characters",
                    comment: "error expectation: minimum length(min # characters)"), expected)
            
        case .tooSimple(let complexityRulesDescription):
            return complexityRulesDescription
            
        case .invalidPinCharacter(_, let expected):
            return String.localizedStringWithFormat(
                NSLocalizedString(
                    "expected characters in range [%s]",
                    comment: "error expectation: valid characters(character range)"),
                expected
            )
            
        case .confirmationMismatch:
            return nil
        }
    }
    var actual: String? {
        switch self {
        case .tooLong(let actual, _), .tooShort(let actual, _):
            return String(actual)
            
        case .invalidPinCharacter(let actual, _):
            return "\(actual)"
        case .tooSimple, .confirmationMismatch:
            return nil
        }
    }
}
