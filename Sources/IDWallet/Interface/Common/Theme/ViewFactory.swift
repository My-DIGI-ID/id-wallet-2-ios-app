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

protocol ViewFactory: ThemeContextDependent {
    associatedtype ViewIDType: BaseViewID
    
    func controlledView(_ id: ViewIDType) -> UIView?
    func addControlledView<T: UIView>(_ id: ViewIDType, view: T, in parent: UIView?) -> T
}

extension ViewFactory {
    /// Returns the controlled view registered with the specified ID if defined, asserting  that the result has
    /// the specified `type` and, if `parent` is defined, that it is a subview of `parent`.
    ///
    /// - Parameter id: the id used to lookup a view
    /// - Parameter ofType: the expected type, a mismatch is considered a fatal error
    /// - Parameter parent: the results expected super view (if defined), a mismatch is considered a fatal error.
    /// - Returns: the matching view or `nil` if no view is registered for the specified `id`
    func controlledView<T: UIView>(_ id: ViewIDType, ofType: T.Type, parent: UIView? = nil)
    -> T? {
        if let result = controlledView(id) {
            guard let result = result as? T else {
                ContractError.guardAssertionFailed(
                    "view [\(String(describing: result))] with ID \(id) is expected to conform to type " +
                    String(describing: T.self)
                ).fatal()
            }
            if let parent = parent {
                if let actualParent = result.superview {
                    guard actualParent === parent else {
                        ContractError.guardAssertionFailed(
                            "view [\(String(describing: result))] is expected to be a subview of [" +
                            String(describing: parent) + "] but is subview of [\(String(describing: actualParent))]"
                        ).fatal()
                    }
                }
            }
            return result
        }
        return nil
    }
    
    // MARK: - Generic Views
    
    private func makeOrGetView(_ id: ViewIDType, in parent: UIView? = nil, didMake: inout Bool)
    -> UIView {
        var result = controlledView(id, ofType: UIView.self, parent: parent)
        if result == nil {
            result = addControlledView(id, view: UIView(), in: parent)
            didMake = true
        }
        return result!
    }
    
    /// Creates or updates a generic ``UIView``
    ///
    /// - Parameter id: A unique ``BaseViewContainer.ViewID`` used as ``accessibilityIdentifier``
    /// - Parameter parent: The view's superview.
    @discardableResult
    func makeOrUpdateView(id: ViewIDType, in parent: UIView? = nil, didMake: inout Bool, _ then: ((UIView) -> Void)? = nil
    ) -> UIView {
        let result = makeOrGetView(id, in: parent, didMake: &didMake)
        then?(result)
        return result
    }
    
    // MARK: Layout Views
    
    /// Creates or updates a generic ``UIView`` to be used as container.
    ///
    /// - Parameter id: A unique ``BaseViewContainer.ViewID`` used as ``accessibilityIdentifier``
    /// - Parameter parent: The view's superview.
    @discardableResult
    func makeOrUpdateContainer(id: ViewIDType, in parent: UIView? = nil, didMake: inout Bool, _ then: ((UIView, inout Bool) -> Void)? = nil
    ) -> UIView {
        let result = makeOrGetView(id, in: parent, didMake: &didMake)
        var closureDidMake: Bool = didMake
        then?(result, &closureDidMake)
        didMake = closureDidMake
        return result
    }
    
    /// Creates or updates a generic ``UIView`` to be used as container.
    ///
    /// - Parameter id: A unique ``BaseViewContainer.ViewID`` used as ``accessibilityIdentifier``
    /// - Parameter parent: The view's superview.
    @discardableResult
    func makeOrUpdateAlignmentWrapper(
        id: ViewIDType,
        horizontalAlignment: AlignmentWrapperView.HorizontalAlignment? = nil,
        verticalAlignment: AlignmentWrapperView.VerticalAlignment? = nil,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((AlignmentWrapperView, inout Bool) -> Void)? = nil
    ) -> AlignmentWrapperView {
        var result = controlledView(id, ofType: AlignmentWrapperView.self, parent: parent)
        if result == nil {
            result = addControlledView(id, view: AlignmentWrapperView(), in: parent)
            didMake = true
        }
        
        guard let result = result else { ContractError.guardAssertionFailed().fatal() }
        
        if let horizontalAlignment = horizontalAlignment {
            result.horizontalAlignment = horizontalAlignment
        }
        if let verticalAlignment = verticalAlignment {
            result.verticalAlignment = verticalAlignment
        }
        var closureDidMake: Bool = didMake
        then?(result, &closureDidMake)
        didMake = closureDidMake
        return result
    }
    
    @discardableResult
    func makeOrUpdateVStack(
        id: ViewIDType,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        spacing: CGFloat? = nil,
        removeExistingArrangedViews: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIStackView, inout Bool) -> Void)? = nil
    ) -> UIStackView {
        return makeOrUpdateStackView(
            id: id,
            axis: .vertical, alignment: alignment, distribution: distribution, spacing: spacing,
            removeExistingArrangedViews: removeExistingArrangedViews,
            in: parent, didMake: &didMake, then)
    }
    
    @discardableResult
    func makeOrUpdateHStack(
        id: ViewIDType,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        spacing: CGFloat? = nil,
        removeExistingArrangedViews: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIStackView, inout Bool) -> Void)? = nil
    ) -> UIStackView {
        return makeOrUpdateStackView(
            id: id,
            axis: .horizontal, alignment: alignment, distribution: distribution, spacing: spacing,
            removeExistingArrangedViews: removeExistingArrangedViews,
            in: parent, didMake: &didMake, then)
    }
    
    @discardableResult
    func makeOrUpdateStackView(
        id: ViewIDType,
        axis: NSLayoutConstraint.Axis? = nil,
        alignment: UIStackView.Alignment? = nil,
        distribution: UIStackView.Distribution? = nil,
        spacing: CGFloat? = nil,
        removeExistingArrangedViews: Bool = true,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIStackView, inout Bool) -> Void)? = nil
    ) -> UIStackView {
        var result = controlledView(id, ofType: UIStackView.self, parent: parent)
        if let result = result {
            if removeExistingArrangedViews {
                while !result.arrangedSubviews.isEmpty {
                    result.removeArrangedSubview(result.arrangedSubviews.last!)
                }
            }
        } else {
            result = addControlledView(id, view: UIStackView(), in: parent)
            didMake = true
        }
        
        if let result = result {  // this is always true, just convenient
            if let axis = axis {
                result.axis = axis
            }
            if let alignment = alignment {
                result.alignment = alignment
            }
            if let distribution = distribution {
                result.distribution = distribution
            }
            if let spacing = spacing {
                result.spacing = spacing
            }
        }
        
        var closureDidMake: Bool = didMake
        then?(result!, &closureDidMake)
        didMake = closureDidMake
        
        return result!
    }
    
    // MARK: - Labels
    
    private func makeOrGetLabel(
        _ id: ViewIDType, text: String?, in parent: UIView? = nil, didMake: inout Bool
    ) -> UILabel {
        var result = controlledView(id, ofType: UILabel.self, parent: parent)
        if result == nil {
            result = addControlledView(id, view: UILabel(), in: parent)
            didMake = true
        }
        if let text = text {
            result!.text = text
        }
        return result!
    }
    
    @discardableResult
    func makeOrUpdateTitle(id: ViewIDType, text: String? = nil, in parent: UIView? = nil, didMake: inout Bool, _ then: ((UILabel) -> Void)? = nil
    ) -> UILabel {
        let result = themeContext.applyTitleStyles(
            label: makeOrGetLabel(id, text: text, in: parent, didMake: &didMake))!
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateHeading(id: ViewIDType, text: String? = nil, in parent: UIView? = nil, didMake: inout Bool, _ then: ((UILabel) -> Void)? = nil
    ) -> UILabel {
        let result = themeContext.applyHeadingStyles(
            label: makeOrGetLabel(id, text: text, in: parent, didMake: &didMake))!
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateSubHeading(id: ViewIDType, text: String? = nil, in parent: UIView? = nil, didMake: inout Bool, _ then: ((UILabel) -> Void)? = nil
    ) -> UILabel {
        let result = themeContext.applySubHeadingStyles(
            label: makeOrGetLabel(id, text: text, in: parent, didMake: &didMake))!
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateBody(id: ViewIDType, text: String? = nil, in parent: UIView? = nil, didMake: inout Bool, _ then: ((UILabel) -> Void)? = nil
    ) -> UILabel {
        let result = themeContext.applyBodyStyles(
            label: makeOrGetLabel(id, text: text, in: parent, didMake: &didMake))!
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateBoldBody(id: ViewIDType, text: String? = nil, in parent: UIView? = nil, didMake: inout Bool, _ then: ((UILabel) -> Void)? = nil
    ) -> UILabel {
        let result = themeContext.applyBoldBodyStyles(
            label: makeOrGetLabel(id, text: text, in: parent, didMake: &didMake))!
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateTipTitle(id: ViewIDType, text: String? = nil, in parent: UIView? = nil, didMake: inout Bool, _ then: ((UILabel) -> Void)? = nil
    ) -> UILabel {
        let result = themeContext.applyBoldBodyStyles(
            label: makeOrGetLabel(id, text: text, in: parent, didMake: &didMake))!
        then?(result)
        return result
    }
    
    // MARK: - Buttons
    
    private func makeOrGetButton(_ id: ViewIDType, title: String?, isEnabled: Bool = false, in parent: UIView? = nil, didMake: inout Bool
    ) -> UIButton {
        var result = controlledView(id, ofType: UIButton.self, parent: parent)
        if result == nil {
            result = addControlledView(id, view: UIButton(), in: parent)
            didMake = true
        }
        if let title = title {
            result!.setTitle(title, for: .normal)
        }
        
        result!.isEnabled = isEnabled
        return result!
    }
    
    @discardableResult
    func makeOrUpdatePrimaryActionButton(
        id: ViewIDType,
        title: String? = nil,
        isEnabled: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIButton) -> Void)? = nil
    ) -> UIButton {
        let result = themeContext.applyPrimaryActionButtonStyles(
            button: makeOrGetButton(id, title: title, isEnabled: isEnabled, in: parent, didMake: &didMake)
        )!
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateSecondaryActionButton(
        id: ViewIDType,
        title: String? = nil,
        isEnabled: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIButton) -> Void)? = nil
    ) -> UIButton {
        let result = themeContext.applySecondaryActionButtonStyles(
            button: makeOrGetButton(id, title: title, isEnabled: isEnabled, in: parent, didMake: &didMake)
        )!
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateSymbolButton(
        id: ViewIDType,
        systemName: String? = nil,
        isEnabled: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIButton) -> Void)? = nil
    ) -> UIButton {
        let result = themeContext.applyLinkButtonStyles(
            button: makeOrGetButton(id, title: nil, isEnabled: isEnabled, in: parent, didMake: &didMake))!
        if let systemName = systemName {
            result.setImage(UIImage(systemName: systemName), for: .normal)
        }
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateCloseButton(
        id: ViewIDType,
        isEnabled: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIButton) -> Void)? = nil
    ) -> UIButton {
        var localDidMake = didMake
        let result = makeOrUpdateSymbolButton(
            id: id, systemName: "xmark", isEnabled: isEnabled, in: parent, didMake: &localDidMake
        ) { button in
            button.tintColor = self.themeContext.colors.textColor
            then?(button)
        }
        return result
    }
    
    @discardableResult
    func makeOrUpdateLinkButton(
        id: ViewIDType,
        title: String? = nil,
        isEnabled: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIButton) -> Void)? = nil
    ) -> UIButton {
        let result = themeContext.applyLinkButtonStyles(
            button: makeOrGetButton(id, title: title, isEnabled: isEnabled, in: parent, didMake: &didMake)
        )!
        then?(result)
        return result
    }
    
    @discardableResult
    func makeOrUpdateExternalLinkButton(
        id: ViewIDType,
        title: String? = nil,
        isEnabled: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIButton) -> Void)? = nil
    ) -> UIButton {
        let result = themeContext.applyExternalLinkButtonStyles(
            button: makeOrGetButton(id, title: title, isEnabled: isEnabled, in: parent, didMake: &didMake)
        )!
        then?(result)
        return result
    }
    
    // MARK: - Other views
    
    @discardableResult
    func makeOrUpdatePinCodeView(
        id: ViewIDType,
        style pinCodeStyle: PinCodeView.Style? = nil,
        pin: [PinCharacterRepresentation]? = nil,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((PinCodeView) -> Void)? = nil
    ) -> PinCodeView {
        var result = controlledView(id, ofType: PinCodeView.self, parent: parent)
        if result == nil {
            result = addControlledView(
                id,
                view: PinCodeView(
                    style: pinCodeStyle
                    ?? PinCodeView.Style(
                        colors: themeContext.colors, spacing: 24.0)),
                in: parent)
            didMake = true
        }
        if let pin = pin {
            result!.pin = pin
        }
        then?(result!)
        return result!
    }
    
    @discardableResult
    func makeOrUpdateNumberPad(
        id: ViewIDType,
        style numberPadStyle: NumberPad.Style? = nil,
        addEnabled: Bool = false,
        deleteEnabled: Bool = false,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((NumberPad) -> Void)? = nil
    ) -> NumberPad {
        var result = controlledView(id, ofType: NumberPad.self, parent: parent)
        if result == nil {
            result = addControlledView(
                id, view: NumberPad(style: numberPadStyle ?? NumberPad.Style(themeContext)),
                in: parent)
            didMake = true
        }
        result!.canAddDigit = addEnabled
        result!.canRemoveLastDigit = deleteEnabled
        then?(result!)
        return result!
    }
    
    @discardableResult
    func makeOrUpdateImageView(
        id: ViewIDType,
        image: ImageNameIdentifier? = nil,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIImageView) -> Void)? = nil
    ) -> UIImageView {
        var result = controlledView(id, ofType: UIImageView.self, parent: parent)
        if result == nil {
            if let image = image {
                result = UIImageView(identifiedBy: image)
            } else {
                result = UIImageView()
            }
            _ = addControlledView(id, view: result!, in: parent)
            didMake = true
        }
        then?(result!)
        return result!
    }
    
    @discardableResult
    func makeOrUpdatePageControl(
        id: ViewIDType,
        in parent: UIView? = nil,
        didMake: inout Bool,
        _ then: ((UIPageControl) -> Void)? = nil
    ) -> UIPageControl {
        var result = controlledView(id, ofType: UIPageControl.self, parent: parent)
        if result == nil {
            result = addControlledView(id, view: UIPageControl(), in: parent)
            themeContext.applyPageControlStyles(pageControl: result)
            didMake = true
        }
        then?(result!)
        return result!
    }
}
