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

import UIKit

// Note: To add more fonts:
// - Add them to the fonts directory (I copied all sans-variants to make it easier
//   to add them but only registered those which are actually used)
// - Register in Supporting Files/info.plist (see "fonts provided by application")
// - Create a func here to make them discoverable in code

extension UIFont {
    static func plexSans(_ size: CGFloat) -> UIFont {
        return .requiredFont(name: "IBMPlexSans", size: size)
    }
    static func plexSansBold(_ size: CGFloat) -> UIFont {
        return .requiredFont(name: "IBMPlexSans-Bold", size: size)
    }
}
