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

extension NSAttributedString {
    func centered() -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        mutableAttrString.addAttributes([.paragraphStyle: paragraph], range: NSRange(0..<self.length))
        return mutableAttrString
    }

    func leftAligned() -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left

        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        mutableAttrString.addAttributes([.paragraphStyle: paragraph],
                                        range: NSRange(0..<self.length))
        return mutableAttrString
    }

    func rightAligned() -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .right

        let mutableAttrString = NSMutableAttributedString(attributedString: self)
        mutableAttrString.addAttributes([.paragraphStyle: paragraph],
                                        range: NSRange(0..<self.length))
        return mutableAttrString
    }
}
