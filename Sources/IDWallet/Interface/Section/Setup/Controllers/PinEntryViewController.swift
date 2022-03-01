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

import Combine
import UIKit

// MARK: - Configuration

private enum Constants {
    enum Styles {
        static let backgroundColor: UIColor = .primaryBlue
        static let textColor: UIColor = .white
        static let titleFont: UIFont = .plexSansBold(15.0)
        static let headerFont: UIFont = .plexSansBold(25.0)
        static let subHeaderFont: UIFont = .plexSans(17.0)
        static let subHeaderTextColor: UIColor = .white
        static let commitButtonFont: UIFont = .plexSansBold(15.0)
    }

    enum Layout {
        static let paddingTop = 60.0
        static let paddingBottom = 48.0
        static let paddingHorizontal = 24.0

        static let primaryButtonWidth = 200.0
    }
}

// MARK: -
// MARK: - PinEntryViewController

class PinEntryViewController: BaseViewController, NumberPadDelegate {
    
    // MARK: - Views

    enum ViewID: String, BaseViewID {
        case containerView
        case headerContainer
        case titleLabel
        case cancelButton

        case textContentContainer
        case headingLabel
        case subHeadingLabel
        case pinCodeView

        case footerContainer
        case numberPad
        case commitButton

        var key: String { rawValue }
    }

    lazy var containerView: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.containerView.key

        result.axis = .vertical

        result.addArrangedSubview(headerContainer)
        result.addArrangedSubview(textContentContainer)
        result.addArrangedSubview(pinCodeContainer)
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

        result.text = viewModel.presentation.title
        result.font = Constants.Styles.titleFont
        result.textColor = Constants.Styles.textColor
        result.textAlignment = .center

        return result
    }()

    lazy var cancelButton: UIButton = {
        let result = UIButton()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.cancelButton.key

        result.setImage(.init(systemName: "xmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)

        result.addAction(.init(handler: { [weak self] _ in if let self = self {
            self.viewModel.cancel(self)
        }}), for: .touchUpInside)

        return result
    }()

    lazy var textContentContainer: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.textContentContainer.key

        result.axis = .vertical

        result.addArrangedSubview(headingLabel)
        result.addArrangedSubview(subHeadingLabel)

        return result
    }()

    lazy var headingLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.headerContainer.key

        result.text = viewModel.presentation.heading
        result.font = Constants.Styles.headerFont
        result.textColor = Constants.Styles.textColor
        result.textAlignment = .center
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping

        return result
    }()

    lazy var subHeadingLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.subHeadingLabel.key

        result.text = viewModel.presentation.subHeading
        result.font = Constants.Styles.subHeaderFont
        result.textColor = Constants.Styles.subHeaderTextColor
        result.textAlignment = .center
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping

        return result
    }()

    lazy var pinCodeContainer: AlignmentWrapperView = {
        let result = AlignmentWrapperView()

        result.translatesAutoresizingMaskIntoConstraints = false

        result.horizontalAlignment = .center
        result.verticalAlignment = .center

        result.arrangedView = pinCodeView

        return result
    }()

    lazy var pinCodeView: PinCodeView = {
        let result = PinCodeView(pin: viewModel.pin)

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.pinCodeView.key

        return result
    }()

    lazy var footerContainer: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.footerContainer.key

        result.axis = .vertical

        result.addArrangedSubview(numberPad)
        result.addArrangedSubview(commitButton)

        return result
    }()

    lazy var numberPad: NumberPad = {
        let result = NumberPad()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.numberPad.key

        return result
    }()

    lazy var commitButton: WalletButton = {
        let result = WalletButton(
            titleText: viewModel.presentation.commitActionTitle,
            image: nil,
            imageAlignRight: false,
            style: WalletButton.Style(
                normal: WalletButton.Style.Color(
                    backgroundColor: .white,
                    borderColor: .clear,
                    textColor: .primaryBlue
                ),
                disabled: WalletButton.Style.Color(
                    backgroundColor: .white.withAlphaComponent(0.15),
                    borderColor: .clear,
                    textColor: .white.withAlphaComponent(0.3)
                )
            ),
            primaryAction: .init(handler: { [weak self] _ in if let self = self {
                guard self.viewModel.canCommit else {
                    return
                }
                self.viewModel.commit(self)
            }})
        )

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.commitButton.key

        return result
    }()

    // MARK: - Configuration & State

    let viewModel: PinEntryViewModel

    var subscriptions: [AnyCancellable] = []

    // MARK: - Initialization

    init(viewModel: PinEntryViewModel) {
        self.viewModel = viewModel
        super.init()
        self.preferredStatusBarStyle = .lightContent
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .primaryBlue
        view.addSubview(containerView)
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard subscriptions.isEmpty else { return }

        numberPad.delegate = self

        let animationDuration = 0.25
        subscriptions = [
            viewModel.$presentation.sink { presentation in
                self.titleLabel.text = presentation.title
                self.headingLabel.text = presentation.heading
                self.subHeadingLabel.text = presentation.subHeading
                self.commitButton.setTitle(presentation.commitActionTitle, for: .normal)
            },
            viewModel.$canCommit.sink { canCommit in
                if self.viewModel.autoCommit {
                    self.commitButton.isHidden = true
                }
                self.commitButton.isEnabled = canCommit
            },
            viewModel.$pin.sink { value in
                UIView.animate(withDuration: animationDuration) {
                    self.pinCodeView.pin = value
                }
            }
        ]
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        numberPad.delegate = nil

        subscriptions = []
    }

    // MARK: - Actions

    func numberPadDidRemoveLastDigit(_ numberPad: NumberPad) {
        if viewModel.canRemove {
            viewModel.remove()
        }
    }

    func numberPad(_ numberPad: NumberPad, didAddDigit digit: String) {
        if viewModel.canAdd && viewModel.isValidPinCharacter(digit) {
            viewModel.add(digit, viewController: self)
        }
    }

    // MARK: - Layout

    func setupLayout() {
        containerView.distribution = .equalSpacing
        containerView.alignment = .fill

        headerContainer.distribution = .fill
        headerContainer.alignment = .firstBaseline

        textContentContainer.spacing = 24.0
        textContentContainer.alignment = .fill

        footerContainer.spacing = 0
        footerContainer.alignment = .center

        [
            "V:|-(padTop)-[container]-(padBot)-|",
            "H:|-(padH)-[container]-(padH)-|",
        ].constraints(
            with: [
                "container": containerView
            ], metrics: [
                "padTop": Constants.Layout.paddingTop,
                "padBot": Constants.Layout.paddingBottom,
                "padH": Constants.Layout.paddingHorizontal
            ]
        ).activate()

        [
            commitButton.centerXAnchor.constraint(
                equalTo: containerView.centerXAnchor),
            commitButton.widthAnchor.constraint(
                equalToConstant: Constants.Layout.primaryButtonWidth),
            // Just testing:
            pinCodeView.widthAnchor.constraint(equalToConstant: 206.0)
        ].activate()
    }
}
