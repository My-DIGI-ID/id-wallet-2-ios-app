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

private enum Constants {
    struct Styles {
        static let spacing: CGFloat = 24.0
        static let digitStyle: PinCodeDigitView.Style = PinCodeDigitView.Style()
    }
}

class PinCodeView: UIView {
    fileprivate typealias Styles = Constants.Styles
    
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
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOnce()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOnce()
    }
    
    convenience init(pin: [PinCharacterRepresentation] = []) {
        self.init(frame: .zero)
        self.pin = pin
    }
    
    // MARK: - Setup

    func setupOnce() {
        self.accessibilityIdentifier = "PinCodeView"
        setContentHuggingPriority(.required, for: .horizontal)
    }

    func updateViews() {
        let lastIndexToUpdate = min(controlledViews.count, pin.count) - 1
        if controlledViews.count > pin.count {
            for index in pin.count...(controlledViews.count - 1) {
                controlledViews[index].removeFromSuperview()
            }
            controlledViews.removeLast(controlledViews.count - pin.count)
        } else if controlledViews.count < pin.count {
            let digitViewStyle = Constants.Styles.digitStyle
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
        let digitSize: CGFloat = Constants.Styles.digitStyle.size
        let count: CGFloat = CGFloat(pin.count)
        let spacing = Constants.Styles.spacing
        let result = CGSize(
            width: count * digitSize + max(0, count - 1) * spacing + 2,
            height: Constants.Styles.digitStyle.size + 2
        )
        DDLogDebug("PinCodeView: contentSize called: frame=\(frame.size.debugDescription), result=\(result.debugDescription)")
        return result
    }

    override func layoutSubviews() {
        let space = Constants.Styles.spacing
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
