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

@IBDesignable
class Rounded: UIView {
    
    @IBInspectable var fillColor: UIColor? {
        didSet { update() }
    }
    @IBInspectable var strokeColor: UIColor? {
        didSet { update() }
    }
    
    @IBInspectable var strokeWidth: CGFloat = 0 {
        didSet { update() }
    }
    
    @IBInspectable var width: CGFloat = -1 {
        didSet { update() }
    }
    
    @IBInspectable var height: CGFloat = -1 {
        didSet { update() }
    }
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: width >= 0 ? width : size.width,
            height: height >= 0 ? height : size.height)
    }
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(width, forKey: "width")
        coder.encode(height, forKey: "height")
        if let fillColor = fillColor {
            coder.encode(fillColor, forKey: "fillColor")
        }
        if let strokeColor = strokeColor {
            coder.encode(strokeColor, forKey: "strokeColor")
        }
        coder.encode(strokeWidth, forKey: "strokeWidth")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        update()
    }
    
    func update() {
        let size = layer.frame.size
        let cornerRadius = min(size.height, size.width) / 2
        layer.cornerRadius = cornerRadius
        
        layer.borderWidth = strokeWidth
        layer.borderColor = strokeColor?.cgColor ?? UIColor.clear.cgColor
        layer.backgroundColor = fillColor?.cgColor ?? tintColor.cgColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fillColor = tintColor
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        strokeWidth = coder.decodeDouble(forKey: "strokeWidth")
        strokeColor = coder.decodeObject(forKey: "strokeColor") as? UIColor
        fillColor = coder.decodeObject(forKey: "fillColor") as? UIColor
        width = coder.decodeDouble(forKey: "width")
        height = coder.decodeDouble(forKey: "height")
    }
}
