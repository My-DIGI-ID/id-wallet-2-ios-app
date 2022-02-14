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

// MARK: - Font Registry

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

// MARK: - Typography

struct Typography {
    // We might want to react to global events such as accessibility changes and update
    // well known typographies (we only use the default so far)
    
    static let regular = Typography(
        titleFont: .plexSansBold(15),
        headingFont: .plexSansBold(25),
        subHeadingFont: .plexSans(17),
        bodyFont: .plexSans(15),
        boldBodyFont: .plexSansBold(15),
        buttonFont: .plexSansBold(15),
        numberPadFont: .plexSans(25),
        numberPadAuxiliaryFont: .plexSans(10)
    )
    
    static let compressed = regular
    
    // Approximately 90% of default
    // Looks better than 80%, but unless we desperately
    // need space, it looks better to stick with default
    static let compressed90 = Typography(
        titleFont: .plexSansBold(13),
        headingFont: .plexSansBold(22),
        subHeadingFont: .plexSans(15),
        bodyFont: .plexSans(13),
        boldBodyFont: .plexSansBold(13),
        buttonFont: .plexSansBold(13),
        numberPadFont: .plexSans(22),
        numberPadAuxiliaryFont: .plexSans(9)
    )
    
    // Approximately 80% of default
    // -> Looks too small
    static let compressed80 = Typography(
        titleFont: .plexSansBold(12),
        headingFont: .plexSansBold(20),
        subHeadingFont: .plexSans(14),
        bodyFont: .plexSans(12),
        boldBodyFont: .plexSansBold(12),
        buttonFont: .plexSansBold(12),
        numberPadFont: .plexSans(20),
        numberPadAuxiliaryFont: .plexSans(8)
    )
    
    let titleFont: UIFont
    let headingFont: UIFont
    let subHeadingFont: UIFont
    let bodyFont: UIFont
    let boldBodyFont: UIFont
    let buttonFont: UIFont
    let numberPadFont: UIFont
    let numberPadAuxiliaryFont: UIFont
}
