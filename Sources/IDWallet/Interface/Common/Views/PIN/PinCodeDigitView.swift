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

class PinCodeDigitView: UIView {
    
    // MARK: - Storage
    
    // MARK: Configuration
    
    var style: Style = .regular {
        didSet { setNeedsDisplay() }
    }
    
    var pin: PinCharacterRepresentation = .unsetOptional {
        didSet {
            if oldValue != pin {
                setNeedsDisplay()
            }
        }
    }
    
    // MARK: Presentation State
    private let shapeLayer = CAShapeLayer()
    
    var heightConstraint: NSLayoutConstraint?
    
    var widthConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = "PinCodeDigitView"
        layer.addSublayer(shapeLayer)
        setNeedsDisplay()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.accessibilityIdentifier = "PinCodeDigitView"
        layer.addSublayer(shapeLayer)
        setNeedsDisplay()
    }
    convenience init(style: Style = .regular, pin: PinCharacterRepresentation = .unset) {
        self.init(frame: .zero)
        self.style = style
        self.pin = pin
    }
    
    // MARK: - Layout
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: style.size, height: style.size)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        let size = self.style.size
        let halfSize = min(size / 2, size / 2)
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: halfSize, y: halfSize),
            radius: CGFloat(halfSize - (style.lineWidth / 2)),
            startAngle: CGFloat(0),
            endAngle: CGFloat(Double.pi * 2),
            clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.lineWidth = style.lineWidth
        switch pin {
        case .set, .setHidden:
            shapeLayer.fillColor = style.colors.tintColor.cgColor
            shapeLayer.strokeColor = style.colors.tintColor.cgColor
        case .unset, .unsetOptional:
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = style.colors.tintInactiveColor.cgColor
        case .unsetActive, .unsetOptionalActive:
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = style.colors.tintColor.cgColor
        }
    }
}

// MARK: - Local Types

extension PinCodeDigitView {
    struct Style: Equatable {
        static let regular = Style()
        static let small = Style(size: 12.0)
        
        let colors: ColorScheme
        let lineWidth: CGFloat
        let size: CGFloat
        init(
            colors: ColorScheme = .main,
            lineWidth: CGFloat = 2.0,
            size: CGFloat = 14.0
        ) {
            self.colors = colors
            self.lineWidth = lineWidth
            self.size = size
        }
    }
}
