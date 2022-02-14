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
