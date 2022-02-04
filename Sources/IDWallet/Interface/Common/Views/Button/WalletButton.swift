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

private enum Constants {
    enum Layout {
        static let cornderRadius: CGFloat = 30
        static let borderWidth: CGFloat = 1
        static let insets = UIEdgeInsets(top: 18, left: 32, bottom: 18, right: 32)
        static let imageSpacing: CGFloat = 8
    }
}

class WalletButton: UIButton {

    var style: Style = .primary {
        didSet {
            updateUI()
        }
    }

    var titleText: String? {
        didSet {
            updateUI()
        }
    }

    var buttonImage: UIImage? {
        didSet {
            updateUI()
        }
    }

    override var isEnabled: Bool {
        get {
            super.isEnabled
        }
        set {
            super.isEnabled = newValue
            updateUI()
        }
    }

    private var styleColor: Style.Color {
        style.colorFor(state: state)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = Constants.Layout.cornderRadius
        layer.cornerCurve = .continuous
        contentEdgeInsets = Constants.Layout.insets
        layer.borderWidth = Constants.Layout.borderWidth

        updateUI()
    }

    convenience init(titleText: String? = nil,
                     image: UIImage? = nil,
                     imageAlignRight: Bool = true,
                     style: Style = .primary,
                     primaryAction: UIAction? = nil) {

        self.init(primaryAction: primaryAction)

        self.style = style
        self.titleText = titleText
        self.buttonImage = image
        imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: Constants.Layout.imageSpacing)
        if imageAlignRight {
            semanticContentAttribute = .forceRightToLeft
            imageEdgeInsets = UIEdgeInsets(top: 0, left: Constants.Layout.imageSpacing, bottom: 0, right: 0)
        }

        updateUI()
    }

    private func updateUI() {

        tintColor = styleColor.textColor
        backgroundColor = styleColor.backgroundColor
        layer.borderColor = styleColor.borderColor.cgColor

        setImage(buttonImage, for: .normal)

        setAttributedTitle(NSAttributedString(string: titleText ?? "",
                                              attributes: [.foregroundColor: styleColor.textColor,
                                                           .font: Typography.regular.buttonFont]), for: .normal)
    }
}

extension WalletButton {
    struct Style {
        struct Color {
            let backgroundColor: UIColor
            let borderColor: UIColor
            let textColor: UIColor
        }

        let normal: Color
        let disabled: Color

        func colorFor(state: UIControl.State) -> Color {
            return state.contains(.disabled) ? disabled : normal
        }
    }
}

extension WalletButton.Style {

    static let primary = WalletButton.Style(
        normal: Color(backgroundColor: .primaryBlue,
                      borderColor: .primaryBlue,
                      textColor: .white),
        disabled: Color(backgroundColor: .grey3,
                        borderColor: .grey3,
                        textColor: .grey2))

    static let secondary = WalletButton.Style(
        normal: Color(backgroundColor: .clear,
                      borderColor: .primaryBlue,
                      textColor: .primaryBlue),
        disabled: Color(backgroundColor: .clear,
                        borderColor: .grey2,
                        textColor: .grey2))

    static let link = WalletButton.Style(
        normal: Color(backgroundColor: .clear,
                      borderColor: .clear,
                      textColor: .primaryBlue),
        disabled: Color(backgroundColor: .clear,
                        borderColor: .clear,
                        textColor: .grey2))
}
