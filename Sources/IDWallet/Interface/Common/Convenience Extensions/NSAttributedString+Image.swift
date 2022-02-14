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
    func add(image: UIImage, leading: Bool = true, imageSize: CGSize = CGSize(width: 24, height: 24), spacing: Int = 16) -> NSAttributedString {
        var capHeight = imageSize.width
        self.enumerateAttributes(in: NSRange(0..<self.length), options: .longestEffectiveRangeNotRequired) { attribs, _, _ in
            guard let value = attribs.first(where: { $0.key == NSAttributedString.Key.font })?.value as? UIFont else { return }
            capHeight = value.capHeight
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRect(x: 0, y: (capHeight - imageSize.width) * 0.5, width: imageSize.width, height: imageSize.height)
        
        let padding = NSTextAttachment()
        padding.bounds = CGRect(origin: .zero, size: .init(width: spacing, height: 0))
        
        let attachmentString = NSAttributedString(attachment: attachment)
        let paddingString = NSAttributedString(attachment: padding)
        
        if leading {
            let mutableAttributedString = NSMutableAttributedString()
            mutableAttributedString.append(attachmentString)
            mutableAttributedString.append(paddingString)
            mutableAttributedString.append(self)
            return mutableAttributedString
        } else {
            let mutableAttributedString = NSMutableAttributedString(attributedString: self)
            mutableAttributedString.append(paddingString)
            mutableAttributedString.append(attachmentString)
            return mutableAttributedString
        }
    }
    
    func prepend(image: UIImage, size: CGSize = CGSize(width: 24, height: 24), spacing: Int = 16) -> NSAttributedString {
        self.add(image: image, leading: true, imageSize: size, spacing: spacing)
    }
    
    func append(image: UIImage, size: CGSize = CGSize(width: 24, height: 24), spacing: Int = 16) -> NSAttributedString {
        self.add(image: image, leading: false, imageSize: size, spacing: spacing)
    }
}
