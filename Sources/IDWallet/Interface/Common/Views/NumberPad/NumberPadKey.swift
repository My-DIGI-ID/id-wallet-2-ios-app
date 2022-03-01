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

// MARK: - Configuration
// MARK: -

private enum Constants {
    enum Style {
        static let numberPadFont: UIFont = .plexSans(25)
        static let numberPadAuxiliaryFont: UIFont = .plexSans(10)
        static let color: UIColor = .white
        static let constrastColor: UIColor = color.withAlphaComponent(0.5)

        static let touchAnimationDuration = 0.25
    }

    enum Layout {
        static let horizontalPadding = 30.0
        static let verticalPadding = 20.0
        static let auxiliarySpacing = -2.0
        static let aixilliaryMinPadding = 10.0
    }
}

extension NumberPadKey {
    enum ViewID: BaseViewID {
        case container
        case keyContainer(_ character: Character)
        case key(_ character: Character)
        case secondaryKey(_ text: String)
        case deleteKey
        var key: String {
            switch self {
            case .container:
                return "NumberPadContainer"
            case .keyContainer(let character):
                return "NumberPadKeyContainer_\(character)"
            case .key(let character):
                return "NumberPadKey_\(character)"
            case .secondaryKey(let text):
                return "NumberPadKey_\(text)"
            case .deleteKey:
                return "NumberPadKey_Delete"
            }
        }
    }

    enum TouchState {
        case idle
        case down
        case up
        case cancelled
    }
}

// MARK: - NumberPadKey
// MARK: -

///
/// Key designed to be used by a custom number key pad.
///
/// Displays the primary key label (a number) and optionally secondary key labels (letters).
///
class NumberPadKey: UIControl {

    var primaryKey: String {
        get { primaryKeyLabel.text ?? "" }
        set(value) {
            if primaryKeyLabel.text != value {
                primaryKeyLabel.text = value
                self.accessibilityIdentifier = "Key_CodeChar_\(value)"
            }
        }
    }
    var secondaryKeys: String {
        get { secondaryKeysLabel.text ?? "" }
        set(value) {
            if secondaryKeysLabel.text != value {
                secondaryKeysLabel.text = value
            }
        }
    }
    
    // MARK: State
    
    override var isEnabled: Bool {
        get { super.isEnabled }
        set(value) {
            if super.isEnabled != value {
                super.isEnabled = value
            }
        }
    }

    fileprivate lazy var container: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false

        result.axis = .vertical
        result.spacing = Constants.Layout.auxiliarySpacing
        result.alignment = .fill

        result.addArrangedSubview(primaryKeyLabel)
        result.addArrangedSubview(secondaryKeysLabel)

        result.isUserInteractionEnabled = false

        return result
    }()

    fileprivate lazy var primaryKeyLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false

        result.textColor = Constants.Style.color
        result.font = Constants.Style.numberPadFont
        result.backgroundColor = .clear
        result.textAlignment = .center

        result.isUserInteractionEnabled = false

        return result
    }()
    
    fileprivate var secondaryKeysLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false

        result.textColor = Constants.Style.color
        result.font = Constants.Style.numberPadAuxiliaryFont
        result.backgroundColor = .clear
        result.textAlignment = .center

        result.isUserInteractionEnabled = false

        return result
    }()
    
    private var touchState: TouchState = .idle {
        didSet {
            guard touchState != oldValue else { return }
            
            switch touchState {
            case .idle:
                break
            case .down:
                performTouchDownAnimations()
            case .up:
                performTouchUpAnimations { _ in
                    self.touchState = .idle
                }
            case .cancelled:
                performTouchCancelledAnimations { _ in
                    self.touchState = .idle
                }
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: (
                CGFloat(Constants.Layout.horizontalPadding * 2) + max(
                    primaryKeyLabel.intrinsicContentSize.width,
                    secondaryKeysLabel.intrinsicContentSize.width)),
            height: (
                CGFloat(Constants.Layout.verticalPadding * 2) +
                primaryKeyLabel.intrinsicContentSize.height +
                secondaryKeysLabel.intrinsicContentSize.height +
                CGFloat(Constants.Layout.auxiliarySpacing))
        )
    }
    
    /// This view will not work using autoresizing
    override final class var requiresConstraintBasedLayout: Bool { return true }
    
    /// Uses the (primary) key label for baseline alignment
    override var forFirstBaselineLayout: UIView { primaryKeyLabel }
    
    /// Uses the (primary) key label for baseline alignment
    override var forLastBaselineLayout: UIView { primaryKeyLabel }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    convenience init(_ primaryKey: String, withSecondaryKeys secondaryKeys: String = "") {
        self.init(frame: CGRect.zero)

        self.primaryKey = primaryKey
        self.secondaryKeys = secondaryKeys
    }

    convenience init(_ primaryKey: String) {
        self.init(primaryKey, withSecondaryKeys: "")
    }

    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(container)

        setupConstraints()
    }
    
    // MARK: - Layout

    /// Sets up constraints if controlledConstraints is empty
    func setupConstraints() {
        let views = [
            "container": container,
            "primary": primaryKeyLabel,
            "secondary": secondaryKeysLabel
        ]
        let metrics = [
            "hPadding": Constants.Layout.horizontalPadding,
            "vPadding": Constants.Layout.verticalPadding,
            "auxSpacing": Constants.Layout.auxiliarySpacing,
            "auxMinPadding": Constants.Layout.auxiliarySpacing,
        ]

        [
            "H:|-(hPadding@249)-[container]-(hPadding@249)-|",
            "V:|-(vPadding)-[container]-(vPadding@249)-|",
        ].constraints(with: views, metrics: metrics, options: []).activate()

        [
            primaryKeyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            primaryKeyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            secondaryKeysLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        ].activate()

        super.updateConstraints()
    }
    
    /// Uses the (primary) key label for alignment
    override func alignmentRect(forFrame frame: CGRect) -> CGRect {
        primaryKeyLabel.alignmentRect(forFrame: frame)
    }
    /// Uses the (primary) key label for alignment
    override func frame(forAlignmentRect alignmentRect: CGRect) -> CGRect {
        primaryKeyLabel.frame(forAlignmentRect: alignmentRect)
    }
}

// MARK: Gesture Tracking

extension NumberPadKey {
    private var extendedBounds: CGRect {
        bounds
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard touchState == .idle else { return false }
        
        let point = touch.location(in: self)
        if extendedBounds.contains(point) {
            touchState = .down
            return true
        } else {
            touchState = .cancelled
            return false
        }
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let point = touch.location(in: self)
        if extendedBounds.contains(point) {
            touchState = .down
            return true
        } else {
            touchState = .cancelled
            return false
        }
    }
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if let point = touch?.location(in: self), extendedBounds.contains(point) {
            touchState = .up
        } else {
            touchState = .cancelled
        }
    }
    override func cancelTracking(with event: UIEvent?) {
        touchState = .cancelled
    }
}

// MARK: - Animation Support

extension NumberPadKey {
    private func animateLabelTextColor(
        color: UIColor, completion: @escaping (Bool) -> Void = { _ in }
    ) {
        UIView.animate(
            withDuration: Constants.Style.touchAnimationDuration,
            animations: {
                UIView.transition(
                    with: self.primaryKeyLabel, duration: Constants.Style.touchAnimationDuration,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.primaryKeyLabel.textColor = color
                    }, completion: nil)
                UIView.transition(
                    with: self.primaryKeyLabel, duration: Constants.Style.touchAnimationDuration,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.secondaryKeysLabel.textColor = color
                    }, completion: nil)
            },
            completion: {
                completion($0)
            })
    }
    
    private func performTouchDownAnimations(_ completion: @escaping (Bool) -> Void = { _ in }) {
        animateLabelTextColor(
            color: Constants.Style.constrastColor, completion: completion)
    }
    
    fileprivate func performTouchUpAnimations(_ completion: @escaping (Bool) -> Void = { _ in }) {
        animateLabelTextColor(color: Constants.Style.color, completion: completion)
    }
    
    fileprivate func performTouchCancelledAnimations(
        _ completion: @escaping (Bool) -> Void = { _ in }
    ) {
        animateLabelTextColor(color: Constants.Style.color, completion: completion)
    }
}
