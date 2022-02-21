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

import CoreGraphics
import UIKit

// MARK: - Conversions between UIColor and hex strings
extension UIColor {
    // MARK: - Mandatory Colors from Assets
    static func requiredColor(named: String) -> UIColor {
        // Explicitly providing the bundle to ensure UI tests can access styles (which in turn
        // require access to asset colors).
        guard let result = UIColor(named: named, in: Bundle(for: CustomFontLoader.self), compatibleWith: nil) else {
            ContractError.missingColor(named).fatal()
        }
        return result
    }
}
