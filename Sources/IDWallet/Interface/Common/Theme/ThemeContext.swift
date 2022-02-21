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

protocol ThemeContextAware {
    var themeContext: ThemeContext? { get }
}

protocol ThemeContextDependent {
    var themeContext: ThemeContext { get }
}

func defaultOrCompressed<T>(_ defaultItem: T, _ compressedItem: T) -> T {
    return UIScreen.main.bounds.height < 750 ? compressedItem : defaultItem
}

struct ThemeContext {
    struct Layout {
        static let regular = Layout(
            primaryButton: .defaultCapsuleLayout(),
            secondaryButton: .defaultCapsuleLayout(borderWidth: 2.0),
            linkButton: .defaultLayout,
            externalLinkButton: .defaultExternalLinkLayout
        )
        static let compressed = Layout(
            primaryButton: .compressedCapsuleLayout(),
            secondaryButton: .compressedCapsuleLayout(borderWidth: 2.0),
            linkButton: .defaultLayout,
            externalLinkButton: .defaultExternalLinkLayout
        )
        
        let primaryButton: ButtonLayout
        let secondaryButton: ButtonLayout
        let linkButton: ButtonLayout
        let externalLinkButton: ButtonLayout
    }
    struct ButtonLayout {
        static let defaultLayout = ButtonLayout(
            minWidth: nil, height: nil, cornerRadius: nil, borderWidth: nil, imagePlacement: nil
        )
        static let defaultExternalLinkLayout = ButtonLayout(
            minWidth: nil, height: nil, cornerRadius: nil, borderWidth: nil, imagePlacement: .trailing
        )
        static func defaultCapsuleLayout(
            borderWidth: CGFloat? = 0.0,
            imagePlacement: ButtonImagePlacement? = nil
        ) -> ButtonLayout {
            return ButtonLayout(
                minWidth: 215.0,
                height: 60.0,
                cornerRadius: 30.0,
                borderWidth: borderWidth,
                imagePlacement: imagePlacement
            )
        }
        static func compressedCapsuleLayout(
            borderWidth: CGFloat? = 0.0,
            imagePlacement: ButtonImagePlacement? = nil
        ) -> ButtonLayout {
            return ButtonLayout(
                minWidth: 215.0,
                height: 40.0,
                cornerRadius: 20.0,
                borderWidth: borderWidth,
                imagePlacement: imagePlacement
            )
        }
        let minWidth: CGFloat?
        let height: CGFloat?
        let cornerRadius: CGFloat?
        let borderWidth: CGFloat?
        let imagePlacement: ButtonImagePlacement?
        func applyTo(button: UIButton) {
            if let minWidth = minWidth {
                button.makeOrUpdateWidthConstraint(width: minWidth, relation: .greaterThanOrEqual)
            }
            if let height = height {
                button.makeOrUpdateHeightConstraint(height: height)
            }
            if let cornerRadius = cornerRadius {
                button.layer.cornerRadius = cornerRadius
            }
            if let borderWidth = borderWidth {
                button.layer.borderWidth = borderWidth
            }
            if let imagePlacement = imagePlacement {
                button.imagePlacement = imagePlacement
            }
        }
    }

    static var main = ThemeContext(
        typography: defaultOrCompressed(.regular, .compressed),
        colors: .main,
        images: .regular,
        layout: defaultOrCompressed(.regular, .compressed)
    )
    static var alternative = ThemeContext(
        typography: defaultOrCompressed(.regular, .compressed),
        colors: .alternative,
        images: .regular,
        layout: defaultOrCompressed(.regular, .compressed)
    )
    let typography: Typography
    let colors: ColorScheme
    let images: Images
    let layout: Layout
}

extension ThemeContext {
    @discardableResult
    func applyPageBackgroundStyles(view: UIView?) -> UIView? {
        if let view = view {
            if colors.backgroundGradient != nil {
                colors.setupBackgroundGradient(view)
            } else {
                view.backgroundColor = colors.backgroundColor
            }
        }
        return view
    }
    @discardableResult
    func applyTitleStyles(label: UILabel?) -> UILabel? {
        if let label = label {
            label.font = typography.titleFont
            label.textColor = colors.textColor
        }
        return label
    }
    @discardableResult
    func applyHeadingStyles(label: UILabel?) -> UILabel? {
        if let label = label {
            label.font = typography.headingFont
            label.textColor = colors.textColor
        }
        return label
    }
    @discardableResult
    func applySubHeadingStyles(label: UILabel?) -> UILabel? {
        if let label = label {
            label.font = typography.subHeadingFont
            label.textColor = colors.textSecondaryColor
        }
        return label
    }
    @discardableResult
    func applyBoldBodyStyles(label: UILabel?) -> UILabel? {
        if let label = label {
            label.font = typography.boldBodyFont
            label.textColor = colors.textColor
        }
        return label
    }
    @discardableResult
    func applyBodyStyles(label: UILabel?) -> UILabel? {
        if let label = label {
            label.font = typography.bodyFont
            label.textColor = colors.textColor
        }
        return label
    }
    @discardableResult
    func applyTipTitleStyles(label: UILabel?) -> UILabel? {
        if let label = label {
            label.font = typography.boldBodyFont
            label.textColor = colors.textColor
        }
        return label
    }
    
    @discardableResult
    func applyPageControlStyles(pageControl: UIPageControl?) -> UIPageControl? {
        if let pageControl = pageControl {
            pageControl.preferredIndicatorImage = images.onboardingActivePageIndicator.withRenderingMode(
                .alwaysTemplate)
            pageControl.pageIndicatorTintColor = colors.tintInactiveColor
            pageControl.currentPageIndicatorTintColor = colors.tintColor
        }
        
        return pageControl
    }
    
    @discardableResult
    func applyButtonStyles(button: UIButton?, layout: ButtonLayout) -> UIButton? {
        if let button = button {
            layout.applyTo(button: button)
            button.titleLabel?.font = typography.buttonFont
        }
        return button
    }
    @discardableResult
    func applyPrimaryActionButtonStyles(button: UIButton?) -> UIButton? {
        if let button = button {
            applyButtonStyles(button: button, layout: layout.primaryButton)
            
            if button.isEnabled {
                button.backgroundColor = colors.tintColor
                button.setTitleColor(colors.tintContrastColor, for: .normal)
            } else {
                button.backgroundColor = colors.tintInactiveColor
                button.setTitleColor(colors.tintInactiveContrastColor, for: .normal)
            }
        }
        return button
    }
    @discardableResult
    func applySecondaryActionButtonStyles(button: UIButton?) -> UIButton? {
        if let button = button {
            applyButtonStyles(button: button, layout: layout.secondaryButton)
            
            if button.isEnabled {
                button.backgroundColor = UIColor.clear
                button.setTitleColor(colors.tintColor, for: .normal)
                button.layer.borderColor = colors.tintColor.cgColor
            } else {
                button.backgroundColor = UIColor.clear
                button.setTitleColor(colors.tintInactiveColor, for: .normal)
                button.layer.borderColor = colors.tintInactiveColor.cgColor
            }
        }
        return button
    }
    @discardableResult
    func applyLinkButtonStyles(button: UIButton?) -> UIButton? {
        if let button = button {
            applyButtonStyles(button: button, layout: layout.linkButton)
            if button.isEnabled {
                button.tintColor = colors.tintColor
                button.setTitleColor(colors.tintColor, for: .normal)
            } else {
                button.tintColor = colors.tintInactiveColor
                button.setTitleColor(colors.tintInactiveColor, for: .normal)
            }
        }
        return button
    }
    
    @discardableResult
    func applyExternalLinkButtonStyles(button: UIButton?) -> UIButton? {
        if let button = button {
            
            applyButtonStyles(button: button, layout: layout.externalLinkButton)
            
            let tintColor = button.isEnabled ? colors.tintColor : colors.tintInactiveColor
            button.tintColor = tintColor
            
            button.setImage(images.externalLinkIcon, for: .normal)
            button.imagePlacement = .trailing
            button.setButtonImagePadding(8)
            button.setTitleColor(tintColor, for: .normal)
            button.titleLabel?.font = typography.buttonFont
        }
        
        return button
    }
}
