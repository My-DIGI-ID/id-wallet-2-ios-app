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

@MainActor
class CustomBarButton: UIControl {
    
    enum Constants {
        static let defaultHorizontalPadding = 0.0
        static let defaultVerticalPadding = 0.0
        static let defaultVerticalSpacing = 2.0
        static let defaultAnimationDuration = 0.15
        static let defaultInactiveAlpha = 0.6
    }
    
    // MARK: - Configuration
    
    var title: String? {
        get { titleLabel.text }
        set(value) { titleLabel.text = value }
    }
    
    var image: UIImage? {
        didSet {
            if !isSelected, image != oldValue {
                imageView.image = image
            }
        }
    }
    
    var selectedImage: UIImage? {
        didSet {
            if isSelected, selectedImage != oldValue {
                imageView.image = selectedImage
            }
        }
    }
    
    var horizontalPadding: CGFloat = Constants.defaultHorizontalPadding
    var verticalPadding: CGFloat = Constants.defaultVerticalPadding
    var verticalSpacing: CGFloat = Constants.defaultVerticalSpacing
    
    var animationDuration: CGFloat = Constants.defaultAnimationDuration
    var animateTouches: Bool = false
    
    var selectedColor: UIColor = .primaryBlue
    var deselectedColor: UIColor = .walBlack
    var inactiveAlpha = Constants.defaultInactiveAlpha
    
    var inactiveColor: UIColor {
        isSelected
        ? selectedColor.withAlphaComponent(inactiveAlpha)
        : deselectedColor.withAlphaComponent(inactiveAlpha)
    }
    var activeColor: UIColor {
        isSelected ? selectedColor : deselectedColor
    }
    
    // MARK: - State
    
    override var isSelected: Bool {
        get { super.isSelected }
        set(value) {
            super.isSelected = value
            updateForStateChange()
        }
    }
    
    override var isEnabled: Bool {
        get { super.isEnabled }
        set(value) {
            super.isEnabled = value
            updateForStateChange()
        }
    }
    
    private(set) lazy var titleLabel: UILabel = { UILabel() }()
    private(set) lazy var imageView: UIImageView = { UIImageView() }()
    
    private var controlledConstraints: [NSLayoutConstraint] = []
    
    private var touchState: CustomBarButton.TouchState = .idle {
        didSet {
            guard touchState != oldValue else {
                return
            }
            
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
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    convenience init(
        title: String?, image: UIImage?, selectedImage: UIImage?
    ) {
        self.init(frame: CGRect.zero)
        
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.isSelected = false
        self.isEnabled = true
    }
    
    convenience init(barItem: UITabBarItem) {
        self.init(
            title: barItem.title,
            image: barItem.image,
            selectedImage: barItem.selectedImage)
    }
    
    // MARK: - Views
    
    func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .plexSans(12)
        addSubview(titleLabel)
        
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
    private func removeControlledConstraints() {
        for constraint in controlledConstraints {
            constraint.isActive = false
            if let first = constraint.firstItem {
                first.removeConstraint(constraint)
            }
            if let second = constraint.secondItem {
                second.removeConstraint(constraint)
            }
        }
        controlledConstraints.removeAll()
    }
    
    override func updateConstraints() {
        removeControlledConstraints()
        updateForStateChange()
        
        let views = [
            "titleLabel": titleLabel,
            "imageView": imageView
        ]
        let metrics = [
            "hPadding": horizontalPadding,
            "vPadding": verticalPadding,
            "vSpacing": verticalSpacing
        ]
        
        controlledConstraints.append(contentsOf: [
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        controlledConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-(>=hPadding,hPadding@1)-[imageView]-(>=hPadding,hPadding@1)-|", metrics: metrics,
                views: views as [String: Any])
        )
        controlledConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-(>=hPadding,hPadding@1)-[titleLabel]-(>=hPadding,hPadding@1)-|",
                metrics: metrics,
                views: views as [String: Any])
        )
        controlledConstraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-(vPadding)-[imageView]-(vSpacing)-[titleLabel]-(vPadding)-|", metrics: metrics,
                views: views as [String: Any])
        )
        
        NSLayoutConstraint.activate(controlledConstraints)
        
        super.updateConstraints()
    }
    
    func updateForStateChange(
        animated: Bool = false,
        completion: ((Bool) -> Void)? = nil
    ) {
        if animated {
            UIView.animate(
                withDuration: animationDuration,
                animations: {
                    UIView.transition(
                        with: self.titleLabel, duration: self.animationDuration,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.titleLabel.text = self.title
                            self.titleLabel.textColor = self.isEnabled
                            ? self.activeColor
                            : self.inactiveColor
                        }, completion: nil)
                    UIView.transition(
                        with: self.imageView, duration: self.animationDuration,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.imageView.image = self.isSelected
                            ? self.selectedImage
                            : self.image
                            self.imageView.alpha = self.isEnabled
                            ? 1.0
                            : self.inactiveAlpha
                        }, completion: nil)
                },
                completion: completion)
        } else {
            titleLabel.text = title
            titleLabel.textColor = isEnabled ? activeColor : inactiveColor
            imageView.image = isSelected ? selectedImage : image
            imageView.alpha = isEnabled ? 1.0 : inactiveAlpha
            completion?(true)
        }
    }
}

extension CustomBarButton {
    override var intrinsicContentSize: CGSize {
        return CGSize(
            width: (
                horizontalPadding +
                max(
                    titleLabel.intrinsicContentSize.width,
                    imageView.intrinsicContentSize.width
                ) +
                horizontalPadding
            ),
            height: (
                verticalPadding +
                titleLabel.intrinsicContentSize.height +
                verticalSpacing +
                imageView.intrinsicContentSize.height +
                verticalPadding
            )
        )
    }
    
    /// This view will not work using autoresizing
    override final class var requiresConstraintBasedLayout: Bool { return true }
    
    /// Uses the title label for baseline alignment
    override var forFirstBaselineLayout: UIView { titleLabel }
    
    /// Uses the title label for baseline alignment
    override var forLastBaselineLayout: UIView { titleLabel }
}

// MARK: Gesture Tracking

extension CustomBarButton {
    enum TouchState {
        case idle
        case down
        case up
        case cancelled
    }
    
    private var extendedBounds: CGRect {
        // extend bounds if touch sensitivity is too narrow
        bounds
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard touchState == .idle else {
            return false
        }
        
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

extension CustomBarButton {
    private func animateTouchState(
        color: UIColor,
        alpha: CGFloat,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        if animateTouches {
            UIView.animate(
                withDuration: animationDuration,
                animations: {
                    UIView.transition(
                        with: self.titleLabel, duration: self.animationDuration,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.titleLabel.textColor = color
                        }, completion: nil)
                    UIView.transition(
                        with: self.imageView, duration: self.animationDuration,
                        options: .transitionCrossDissolve,
                        animations: {
                            self.imageView.alpha = alpha
                        }, completion: nil)
                },
                completion: {
                    completion($0)
                })
        } else {
            completion(true)
        }
    }
    
    private func performTouchDownAnimations(_ completion: @escaping (Bool) -> Void = { _ in }) {
        animateTouchState(
            color: inactiveColor, alpha: self.inactiveAlpha, completion: completion)
    }
    
    private func performTouchUpAnimations(_ completion: @escaping (Bool) -> Void = { _ in }) {
        animateTouchState(
            color: activeColor, alpha: 1.0, completion: completion)
    }
    
    private func performTouchCancelledAnimations(
        _ completion: @escaping (Bool) -> Void = { _ in }
    ) {
        animateTouchState(
            color: activeColor, alpha: 1.0, completion: completion)
    }
}
