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

fileprivate extension ImageNameIdentifier {
    static let exclamation = ImageNameIdentifier(rawValue: "Exclamation")
    static let error = ImageNameIdentifier(rawValue: "Error")
}

private enum Constants {
    enum Styles {
        static let backgroundColor: UIColor = .white
        static let textColor: UIColor = .black
        static let titleFont: UIFont = .plexSans(15.0)
        static let headerFont: UIFont = .plexSansBold(25.0)
        static let subHeaderFont: UIFont = .plexSans(17.0)
        static let subHeaderTextColor: UIColor = .grey1
        static let infoBoxTitleFont: UIFont = .plexSansBold(15.0)
        static let infoBoxFont: UIFont = .plexSans(15.0)
        static let infoBoxIconColor: UIColor = .primaryBlue
        static let infoBoxBackgroundColor: UIColor = .secondaryBlue
        static let infoBoxItemSize: CGSize = CGSize(width: 18.0, height: 18.0)
        static let commitButtonFont: UIFont = .plexSansBold(15.0)
    }

    enum Layout {
        static let paddingTop = 60.0
        static let paddingBottom = 48.0
        static let paddingHorizontal = 24.0

        static let mainContentSpacing = 24.0

        static let infoBoxPadding = 20.0
        static let infoBoxSpacing = 8.0

        static let minPrimaryButtonWidth = 240.0
    }

    enum Texts {
        static var title: String = NSLocalizedString("ID Wallet einrichten", comment: "Page Title")
        static var heading: String = NSLocalizedString("ID Wallet absichern", comment: "Heading")
        static var subHeading: String = NSLocalizedString(
            "Lege einen Zugangscode fest, um Deine ID Wallet vor Zugriff auf andere zu schützen. " +
            "Den Zugangscode brauchst Du bei jeder Nutzung der ID Wallet App.",
            comment: "Sub Heading")
        static var infoBoxTitle: String = NSLocalizedString("Hinweis:", comment: "Tip Title")
        static var infoBoxText: String = NSLocalizedString(
            "Der Zugangscode ist nur auf Deinem Smartphone gespeichert. " +
            "Wenn Du Ihn verlierst, musst Du die App neu installieren und einrichten.",
            comment: "Tip Text")
        static var commitTitle: String = NSLocalizedString("Zugangscode festlegen", comment: "Commit Action Title")
    }
}

// MARK: -

class PinEntryIntroViewController: BaseViewController {

    enum Result {
        case committed
        case cancelled
    }

    // MARK: - Views

    enum ViewID: String, BaseViewID {
        case containerView

        case headerContainer
        case titleLabel
        case cancelButton

        case mainContentContainer
        case headingLabel
        case subHeadingLabel

        case infoBox
        case infoBoxTitleWrapper
        case infoBoxIcon
        case infoBoxTextWrapper
        case infoBoxTitleLabel
        case infoBoxTextLabel

        case footerContainer
        case commitButton

        var key: String { return rawValue }
    }

    lazy var containerView: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.containerView.key

        result.axis = .vertical

        result.addArrangedSubview(headerContainer)
        result.addArrangedSubview(mainContentContainer)
        result.addArrangedSubview(footerContainer)

        return result
    }()

    lazy var headerContainer: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.headerContainer.key

        result.axis = .horizontal

        result.addArrangedSubview(titleLabel)
        result.addArrangedSubview(cancelButton)

        return result
    }()

    lazy var titleLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.titleLabel.key

        result.text = Constants.Texts.title
        result.font = Constants.Styles.infoBoxTitleFont
        result.textColor = Constants.Styles.textColor
        result.textAlignment = .center

        return result
    }()

    lazy var cancelButton: UIButton = {
        let result = UIButton()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.cancelButton.key

        result.setImage(.init(systemName: "xmark")?.withTintColor(.primaryBlue), for: .normal)

        result.addAction(.init(handler: { [weak self] _ in if let self = self { self.completion(self, .cancelled)
        }}), for: .touchUpInside)

        return result
    }()

    lazy var mainContentContainer: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.mainContentContainer.key

        result.axis = .vertical

        result.addArrangedSubview(headingLabel)
        result.addArrangedSubview(subHeadingLabel)
        result.addArrangedSubview(infoBox)

        return result
    }()

    lazy var headingLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.headerContainer.key

        result.text = Constants.Texts.heading
        result.font = Constants.Styles.headerFont
        result.textColor = Constants.Styles.textColor
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping

        return result
    }()

    lazy var subHeadingLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.subHeadingLabel.key

        result.text = Constants.Texts.subHeading
        result.font = Constants.Styles.subHeaderFont
        result.textColor = Constants.Styles.subHeaderTextColor
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping

        return result
    }()

    lazy var infoBox: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.infoBox.key

        result.axis = .vertical

        result.layer.cornerRadius = 15
        result.backgroundColor = .grey7

        result.addArrangedSubview(infoBoxTitleWrapper)
        result.addArrangedSubview(infoBoxTextLabel)

        return result
    }()

    lazy var infoBoxTitleWrapper: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.infoBoxTitleWrapper.key

        result.axis = .horizontal

        result.addArrangedSubview(infoBoxIcon)
        result.addArrangedSubview(infoBoxTitleLabel)

        return result
    }()

    lazy var infoBoxIcon: UIImageView = {
        let result = UIImageView(image: .init(identifiedBy: .error)?.withTintColor(.primaryBlue))

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.infoBoxIcon.key

        [ // Alternatively: resize image, PDF dimensions are not ok
            result.widthAnchor.constraint(equalToConstant: 18),
            result.heightAnchor.constraint(equalToConstant: 18),
        ].activate()

        return result
    }()

    lazy var infoBoxTitleLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.infoBoxTitleLabel.key

        result.text = Constants.Texts.infoBoxTitle
        result.font = Constants.Styles.infoBoxTitleFont
        result.textColor = Constants.Styles.textColor
        result.textAlignment = .left

        return result
    }()

    lazy var infoBoxTextLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.infoBoxTextLabel.key

        result.text = Constants.Texts.infoBoxText
        result.font = Constants.Styles.infoBoxFont
        result.textColor = Constants.Styles.textColor
        result.textAlignment = .left
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .left

        return result
    }()

    lazy var footerContainer: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.footerContainer.key

        result.axis = .vertical

        result.addArrangedSubview(commitButton)

        return result
    }()

    lazy var commitButton: WalletButton = {
        let result = WalletButton(
            titleText: Constants.Texts.commitTitle,
            image: nil,
            imageAlignRight: false,
            style: .primary,
            primaryAction: .init(handler: { [weak self] _ in if let self = self { self.completion(self, .committed)
            }})
        )

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.commitButton.key

        return result
    }()

    // MARK: - Configuration

    let completion: (PinEntryIntroViewController, _ result: Result) -> Void

    // MARK: - Initialization

    init(completion: @escaping (PinEntryIntroViewController, _ result: Result) -> Void) {
        self.completion = completion
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        view.addSubview(self.containerView)
        setupLayout()
    }

    // MARK: - Layout

    func setupLayout() {
        containerView.distribution = .equalCentering
        containerView.alignment = .fill
        containerView.insertArrangedSubview(UIView(), at: 2)

        headerContainer.alignment = .firstBaseline
        headerContainer.distribution = .fill

        mainContentContainer.alignment = .fill
        mainContentContainer.spacing = Constants.Layout.mainContentSpacing

        footerContainer.distribution = .equalSpacing
        footerContainer.alignment = .center

        infoBox.alignment = .fill
        infoBox.distribution = .fill
        infoBox.spacing = Constants.Layout.infoBoxSpacing
        infoBox.isLayoutMarginsRelativeArrangement = true
        infoBox.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Constants.Layout.infoBoxPadding,
            leading: Constants.Layout.infoBoxPadding,
            bottom: Constants.Layout.infoBoxPadding,
            trailing: Constants.Layout.infoBoxPadding)

        infoBoxTitleWrapper.alignment = .fill
        infoBoxTitleWrapper.distribution = .fill
        infoBoxTitleWrapper.spacing = Constants.Layout.infoBoxSpacing

        [
            "V:|-(padTop)-[container]-(padBot)-|",
                "H:|-(padH)-[container]-(padH)-|",
        ].constraints(
            with: [
                "container": containerView,
                "header": headerContainer,
                "main": mainContentContainer,
                "headingLabel": headingLabel,
                "subHeadingLabel": subHeadingLabel,
                "infoBox": infoBox,
                "commit": commitButton,
            ], metrics: [
                "padTop": Constants.Layout.paddingTop,
                "padBot": Constants.Layout.paddingBottom,
                "padH": Constants.Layout.paddingHorizontal
            ]
        ).activate()

        [
            commitButton.centerXAnchor.constraint(
                equalTo: mainContentContainer.centerXAnchor),
            commitButton.widthAnchor.constraint(
                greaterThanOrEqualToConstant: Constants.Layout.minPrimaryButtonWidth)
        ].activate()
    }
}
