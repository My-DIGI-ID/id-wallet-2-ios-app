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
import UIKit

enum AttributedStyle {
    case header,
         subHeading,
         walletCardValueTitle,
         walletCardValue,
         walletCardTitle,
         walletInfoText,
         validityLabel,
         body,
         text(color: UIColor = .walBlack, font: UIFont)  // FIXME: We should not use parameters for the attribute styles.

    var attributes: [NSAttributedString.Key: Any] {
        switch self {
        case .header:
            return [
                .foregroundColor: UIColor.walBlack,
                .font: Typography.regular.headingFont]
        case .subHeading:
            return [.foregroundColor: UIColor.walBlack,
                    .font: Typography.regular.subHeadingFont]
            
        case .walletCardValueTitle:
            return [.foregroundColor: UIColor.walBlack,
                    .font: UIFont.plexSansBold(12)]
        case .walletCardValue:
            return [.foregroundColor: UIColor.walBlack,
                    .font: UIFont.plexSans(12)]
        case .walletCardTitle:
            return [.foregroundColor: UIColor.walBlack,
                    .font: UIFont.plexSans(20)]
        case .walletInfoText:
            return [.foregroundColor: UIColor.grey1,
                    .font: UIFont.plexSans(17)]
        case .validityLabel:
            return [.foregroundColor: UIColor.walBlack,
                    .font: UIFont.plexSans(10)]
        case .body:
            return [
                .foregroundColor: UIColor.walBlack,
                .font: Typography.regular.bodyFont]
        case .text(let color, let font):
            return [
                .foregroundColor: color,
                .font: font]
        }
    }
}

extension String {
    func styledAs(_ style: AttributedStyle) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: self)
        attrString.addAttributes(style.attributes,
                                 range: NSRange(0..<self.count))
        return attrString
    }
}
