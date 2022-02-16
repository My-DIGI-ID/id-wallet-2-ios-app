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

import CocoaLumberjackSwift
import UIKit

class PinCodeView: UIView {
    
    // MARK: - Storage
    
    // MARK: Configuration
    
    var style: Style = Style.regular {
        didSet {
            updateForChangedState()
        }
    }
    
    // MARK: Presentation State
    
    private var controlledViews: [PinCodeDigitView] = []
    
    // MARK: State
    
    var pin: [PinCharacterRepresentation] = [] {
        didSet {
            updateForChangedState()
        }
    }
    
    private func updateForChangedState() {
        updateViews()
        
        setNeedsLayout()
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = "PinCodeView"
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.accessibilityIdentifier = "PinCodeView"
    }
    
    convenience init(style: Style, pin: [PinCharacterRepresentation] = []) {
        self.init(frame: .zero)
        self.style = style
    }
    
    // MARK: - Setup
    
    func updateViews() {
        let lastIndexToUpdate = min(controlledViews.count, pin.count) - 1
        if controlledViews.count > pin.count {
            for index in pin.count...(controlledViews.count - 1) {
                controlledViews[index].removeFromSuperview()
            }
            controlledViews.removeLast(controlledViews.count - pin.count)
        } else if controlledViews.count < pin.count {
            let digitViewStyle = style.digitStyle
            let first = controlledViews.count
            let last = pin.count - 1
            for index in first...last {
                let view = PinCodeDigitView(style: digitViewStyle, pin: pin[index])
                view.accessibilityIdentifier =
                "\(view.accessibilityIdentifier ?? "PinCodeDigitView")_\(index)"
                self.addSubview(view)
                controlledViews.append(view)
            }
        }
        if lastIndexToUpdate >= 0 {
            for index in 0...lastIndexToUpdate {
                controlledViews[index].pin = pin[index]
            }
        }
        setNeedsLayout()
    }
}

// MARK: - Layout

extension PinCodeView {
    override var intrinsicContentSize: CGSize {
        let digitSize: CGFloat = style.digitStyle.size
        let count: CGFloat = CGFloat(pin.count)
        let spacing = style.spacing
        return CGSize(
            width: count * digitSize + max(0, count - 1) * spacing,
            height: self.style.digitStyle.size
        )
    }

    override func layoutSubviews() {
        let space = style.spacing
        var deltaX = bounds.origin.x + 0.0
        let deltaY = bounds.origin.y
        
        for index in 0..<controlledViews.count {
            let view = controlledViews[index]
            view.layoutIfNeeded()
            view.frame.origin = CGPoint(
                x: deltaX, y: deltaY
            )
            view.frame.size = view.intrinsicContentSize
            deltaX += view.frame.width + space
        }
    }
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
}

// MARK: - Local Types

extension PinCodeView {
    struct Style {
        static let small = Style(
            spacing: 16.0,
            digitStyle: .small
        )
        static let regular = Style()
        static let compressed = regular
        
        let colors: ColorScheme
        let spacing: CGFloat
        let digitStyle: PinCodeDigitView.Style
        
        init(
            colors: ColorScheme = .main,
            spacing: CGFloat = 24.0,
            digitStyle: PinCodeDigitView.Style? = nil
        ) {
            self.colors = colors
            self.spacing = spacing
            if let digitStyle = digitStyle {
                self.digitStyle = digitStyle
            } else {
                self.digitStyle = PinCodeDigitView.Style(colors: colors)
            }
        }
    }
}
