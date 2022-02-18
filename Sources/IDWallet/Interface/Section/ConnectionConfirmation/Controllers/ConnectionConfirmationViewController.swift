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
    
    enum Text {
        static let subHeader = "Verbindung erlauben"
    }
    
    enum Layout {
        static let iconSize: CGFloat = 96
        static let stackViewSpacing: CGFloat = 8
        static let scrollBarTopSpacing: CGFloat = 106
        
        static let contenStackViewInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        static let buttonStackViewBottomDistance: CGFloat = -16
        static let buttonStackViewSpacing: CGFloat = 8
        static let headerSpacing: CGFloat = -48
        static let imageSpacing: CGFloat = -32
        
        static let informationViewCornerRadius: CGFloat = 16
        static let informationViewLeading: CGFloat = 24
        static let informationViewHeight: CGFloat = 58
        
        enum Button {
            static let linkHeight: CGFloat = 24
        }
        
        static let spacherHeight: CGFloat = 40
    }
    static let image: UIImage = #imageLiteral(resourceName: "verfified")
    static let checkmark: UIImage = #imageLiteral(resourceName: "solve")
}

enum ConnectionConfirmationResult {
    case confirm
    case cancel
    case deny
}

class ConnectionConfirmationViewController: BareBaseViewController {
    
    private let viewModel: ConnectionConfirmationViewModel
    
    private let completion: (ConnectionConfirmationResult) -> Void
    
    private lazy var allowButton: WalletButton = {
        let result = WalletButton(
            titleText: "Erlauben",
            primaryAction: UIAction(handler: { _ in
                self.completion(.confirm)
            }))
        result.style = .primary
        return result
    }()
    
    private lazy var denyButton: WalletButton = {
        let result = WalletButton(
            titleText: "Abbrechen",
            primaryAction: UIAction(handler: { _ in
                self.completion(.deny)
            }))
        result.style = .secondary
        return result
    }()
    
    //    private lazy var closeButton: UIBarButtonItem = {
    //        let button = UIBarButtonItem(
    //            image: Images.regular.close,
    //            style: .plain,
    //            target: self,
    //            action: #selector(closeView))
    //        button.tintColor = .primaryBlue
    //        button.setTitleTextAttributes([
    //            .foregroundColor: UIColor.primaryBlue,
    //            .font: Typography.regular.bodyFont], for: .normal)
    //        button.setTitleTextAttributes([
    //            .foregroundColor: UIColor.primaryBlue,
    //            .font: Typography.regular.bodyFont], for: .highlighted)
    //        return button
    //    }()
    //
    private lazy var navigationBar: UINavigationBar = {
        //        navigationItem.rightBarButtonItem = closeButton
        
        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.pushItem(navigationItem, animated: false)
        navigationBar.shadowImage = UIImage()
        return navigationBar
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .white
        view.addAutolayoutSubviews(contentView)
        return view
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        return view
    }()
    
    private lazy var headerLabel: UILabel = {
        let header = UILabel(frame: .zero)
        header.numberOfLines = 0
        return header
    }()
    
    private lazy var subHeaderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var alertTypeImageView: UIImageView = {
        return UIImageView(image: Constants.image)
            .withEqualAutolayoutSize(constant: Constants.Layout.iconSize)
    }()
    
    //    private lazy var securedConnectionInformationView: UIView = {
    //        let view = UIView(frame: .zero)
    //        view.translatesAutoresizingMaskIntoConstraints = false
    //        view.backgroundColor = .secondaryBlue
    //        view.layer.cornerRadius = Constants.Layout.informationViewCornerRadius
    //        view.addAutolayoutSubviews(labelSecuredConnection)
    //        return view
    //    }()
    //
    //    private lazy var labelSecuredConnection: UILabel = {
    //        let label = UILabel(frame: .zero)
    //        label.numberOfLines = 1
    //        label.attributedText = "Verbindung ist verschlüsselt"
    //            .styledAs(.body)
    //            .prepend(image: Constants.checkmark)
    //        return label
    //    }()
    
    //    private lazy var certificateInformationView: UIView = {
    //        let view = UIView(frame: .zero)
    //        view.translatesAutoresizingMaskIntoConstraints = false
    //        view.backgroundColor = .secondaryBlue
    //        view.layer.cornerRadius = Constants.Layout.informationViewCornerRadius
    //        view.addAutolayoutSubviews(labelCertificateInformation)
    //        return view
    //    }()
    //
    //    private lazy var labelCertificateInformation: UILabel = {
    //        let label = UILabel(frame: .zero)
    //        label.numberOfLines = 1
    //        label.attributedText = "Zertifikat ist gültig"
    //            .styledAs(.body)
    //            .prepend(image: Constants.checkmark)
    //        return label
    //    }()
    
    //    private lazy var linkSecurity: WalletButton = {
    //        let button = WalletButton(titleText: "Welche Sicherheitsstufe gibt es?",
    //                                  style: .link,
    //                                  primaryAction: nil)
    //        return button
    //    }()
    
    private lazy var linkDetails: WalletButton = {
        let button = WalletButton(
            titleText: "Details zu dieser Verbindung anzeigen",
            style: .link,
            primaryAction: nil)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    let spacer = UIView()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            alertTypeImageView,
            headerLabel,
            subHeaderLabel,
            //            securedConnectionInformationView,
            //            certificateInformationView,
            //            linkSecurity,
            //            linkDetails,
            spacer,
            buttonsStackView])
        view.axis = .vertical
        view.alignment = .center
        view.distribution = .fill
        view.spacing = Constants.Layout.stackViewSpacing
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.addAutolayoutSubviews(stackView)
        return view
    }()
    
    init(viewModel: ConnectionConfirmationViewModel, completion: @escaping (ConnectionConfirmationResult) -> Void) {
        self.viewModel = viewModel
        self.completion = completion
        super.init(style: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        headerLabel.attributedText = viewModel.connection
            .styledAs(.header)
            .centered()
        
        subHeaderLabel.attributedText = Constants.Text.subHeader
            .styledAs(.text(font: .plexSans(25)))
            .centered()
        
        buttonsStackView.addArrangedSubview(allowButton)
        buttonsStackView.addArrangedSubview(denyButton)
    }
    
    @objc
    private func closeView() {
        completion(.cancel)
    }
}

// MARK: Layout

extension ConnectionConfirmationViewController {
    
    private func setupLayout() {
        view.backgroundColor = .white
        
        view.addAutolayoutSubviews(
            //            navigationBar,
            scrollView)
        
        // Layout ScrollView
        scrollView.embed(contentView)
        contentView.embed(stackView, insets: Constants.Layout.contenStackViewInsets)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        // Layout Complete View
        [
            "V:|-(spacing)-[scrollView]-|",
            "H:|[scrollView]|"]
            .constraints(
                with: ["scrollView": scrollView],
                metrics: ["spacing": Constants.Layout.scrollBarTopSpacing])
            .activate()
        
        // Pin the button stackView to the bottom of the view
        let buttonStackViewPinToBottomConstraint = buttonsStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        buttonStackViewPinToBottomConstraint.priority = .defaultLow
        buttonStackViewPinToBottomConstraint.constant = Constants.Layout.buttonStackViewBottomDistance
        buttonStackViewPinToBottomConstraint.isActive = true
        
        buttonsStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        buttonsStackView.spacing = Constants.Layout.buttonStackViewSpacing
        
        NSLayoutConstraint.activate([
            alertTypeImageView.bottomAnchor.constraint(
                equalTo: headerLabel.topAnchor,
                constant: Constants.Layout.imageSpacing),
            headerLabel.bottomAnchor.constraint(
                equalTo: subHeaderLabel.topAnchor,
                constant: Constants.Layout.headerSpacing)
            //            subHeaderLabel.bottomAnchor.constraint(
            //                equalTo: securedConnectionInformationView.topAnchor,
            //                constant: Constants.Layout.headerSpacing),
            //            securedConnectionInformationView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            //            securedConnectionInformationView.heightAnchor.constraint(equalToConstant: Constants.Layout.informationViewHeight),
            //            labelSecuredConnection.centerYAnchor.constraint(equalTo: securedConnectionInformationView.centerYAnchor),
            //            labelSecuredConnection.leadingAnchor.constraint(
            //                equalTo: securedConnectionInformationView.leadingAnchor,
            //                constant: Constants.Layout.informationViewLeading),
            //            certificateInformationView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            //            certificateInformationView.heightAnchor.constraint(equalToConstant: Constants.Layout.informationViewHeight),
            //            labelCertificateInformation.centerYAnchor.constraint(equalTo: certificateInformationView.centerYAnchor),
            //            labelCertificateInformation.leadingAnchor.constraint(
            //                equalTo: certificateInformationView.leadingAnchor,
            //                constant: Constants.Layout.informationViewLeading),
            //            linkSecurity.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            //            linkSecurity.heightAnchor.constraint(equalToConstant: Constants.Layout.Button.linkHeight),
            //            linkDetails.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            //            linkDetails.heightAnchor.constraint(equalToConstant: Constants.Layout.Button.linkHeight),
            //            spacer.heightAnchor.constraint(equalToConstant: Constants.Layout.spacherHeight)
        ])
    }
}
