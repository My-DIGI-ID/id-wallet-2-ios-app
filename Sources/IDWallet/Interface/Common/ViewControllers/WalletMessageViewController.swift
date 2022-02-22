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
    
    enum NavigationBar {
        static let titleFont = Typography.regular.titleFont
    }
    
    enum Layout {
        static let iconSize: CGFloat = 96
        static let stackViewSpacing: CGFloat = 48
        static let scrollBarTopSpacing: CGFloat = 40
        
        static let contenStackViewInsets = UIEdgeInsets(top: 0, left: 48, bottom: 0, right: 48)
        static let buttonStackViewBottomDistance: CGFloat = -16
        static let buttonStackViewSpacing: CGFloat = 8
        
        enum Button {
            static let contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            static let cornerRadius: CGFloat = 30
        }
    }
}

fileprivate extension ImageNameIdentifier {
    static let close = ImageNameIdentifier(rawValue: "Close")
}

class WalletMessageViewController: BareBaseViewController {
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: .init(identifiedBy: .close),
            style: .plain,
            target: self,
            action: #selector(closeView)
        )
        button.tintColor = .primaryBlue
        button.setTitleTextAttributes([
            .foregroundColor: UIColor.primaryBlue,
            .font: Typography.regular.bodyFont
        ], for: .normal)
        button.setTitleTextAttributes([
            .foregroundColor: UIColor.primaryBlue,
            .font: Typography.regular.bodyFont
        ], for: .highlighted)
        return button
    }()
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationItem = UINavigationItem(title: viewModel.title)
        if viewModel.messageType != .success {
            navigationItem.rightBarButtonItem = closeButton
        }
        
        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.walBlack,
            .font: Constants.NavigationBar.titleFont
        ]
        
        navigationBar.shadowImage = UIImage()
        navigationBar.pushItem(navigationItem, animated: false)
        
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
    
    private lazy var messageTypeImageView: UIImageView = {
        return UIImageView(image: viewModel.messageType.image)
            .withEqualAutolayoutSize(constant: Constants.Layout.iconSize)
    }()
    
    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            messageTypeImageView,
            headerLabel,
            subHeaderLabel,
            UIView(),
            buttonsStackView
        ])
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
    
    private let viewModel: MessageModelProtocol
    
    init(viewModel: MessageModelProtocol) {
        self.viewModel = viewModel
        super.init(style: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        headerLabel.attributedText = viewModel.header
            .styledAs(.header)
            .centered()
        
        subHeaderLabel.attributedText = viewModel.text
            .styledAs(.subHeading)
            .centered()

        viewModel.buttons.forEach {
            let button = WalletButton(config: $0)
            buttonsStackView.addArrangedSubview(button)
        }
//        viewModel.buttons.forEach { (title: String, action: UIAction) in
//            let button = WalletButton(titleText: title, primaryAction: action)
//            buttonsStackView.addArrangedSubview(button)
//        }
    }
    @objc
    private func closeView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Layout

extension WalletMessageViewController {
    private func setupLayout() {
        view.backgroundColor = .white
        
        view.addAutolayoutSubviews(navigationBar, scrollView)
        
        // Layout ScrollView
        scrollView.embed(contentView)
        contentView.embed(stackView, insets: Constants.Layout.contenStackViewInsets)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        // Layout Complete View
        [
            "V:|-[navBar]-(spacing)-[scrollView]-|",
            "H:|[navBar]|",
            "H:|[scrollView]|",
        ].constraints(
            with: ["navBar": navigationBar, "scrollView": scrollView],
            metrics: ["spacing": Constants.Layout.scrollBarTopSpacing]
        ).activate()
        
        // Pin the button stackView to the bottom of the view
        let buttonStackViewPinToBottomConstraint = buttonsStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        buttonStackViewPinToBottomConstraint.priority = .defaultLow
        buttonStackViewPinToBottomConstraint.constant = Constants.Layout.buttonStackViewBottomDistance
        buttonStackViewPinToBottomConstraint.isActive = true
        
        buttonsStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        buttonsStackView.spacing = Constants.Layout.buttonStackViewSpacing
    }
}
