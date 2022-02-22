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
    enum Styles {
        static let alphaExpired: CGFloat = 0.8
        static let alphaValid: CGFloat = 1.0
        
        enum Shadow {
            static let color: UIColor = .walBlack
            static let offset: CGSize = .init(width: 0, height: 0)
            static let radius: CGFloat = 3.0
            static let opacity: Float = 0.3
        }
        
        enum Border {
            static let color: UIColor = .white
            static let width: CGFloat = 0.5
        }
    }
    
    enum Layouts {
        static let cardCornerRadius: CGFloat = 16
        static let cardInsetLeftRight: CGFloat = 16
        
        static let validityViewHeightRatio: CGFloat = 24 / 60
        static let walletCardWidthHeightRatio: CGFloat = 327 / 207.5
        static let walletCardHeaderHeightRatio: CGFloat = 60 / 207.5
        
        static let valuesSpacing: CGFloat = 10
        
        static let headerInset: UIEdgeInsets = .init(
            top: 0,
            left: cardInsetLeftRight,
            bottom: 0,
            right: cardInsetLeftRight
        )
        
        static let valuesContainerSpacing: CGFloat = 15
        static let valuesTopSpacing: CGFloat = 8
        static let valuesBottomSpacing: CGFloat = 13
    }
}

extension AttributedStyle {
    static var walletCardTitle: AttributedStyle = .init([
        .foregroundColor: UIColor.walBlack,
        .font: UIFont.plexSans(20)
    ])
}

extension WalletCardModel.TextStyle {
    var color: UIColor {
        switch self {
        case .light: return .white
        case .dark: return .walBlack
        }
    }
}

/// Common UIView implementation that represents the Credentials added to the Wallet as Card
/// A Wallet-Card consists of a title, a validity-marker (invisible, 15h remaining, invalid) and Key-Value pairs
/// displayed on the left (primary) and right (secondary) side of the card.
///
/// The card can be configured using a WalletCardModel.
class WalletCardView: UIView {
    typealias Callback = (WalletCardView) -> Void
    fileprivate typealias Style = Constants.Styles
    fileprivate typealias Layout = Constants.Layouts
    
    // MARK: - Header
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var validityView: WalletValidityView = {
        let view = WalletValidityView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var validityContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(validityView)
        
        let constraints = [
            "H:|[validityView]|"
        ].constraints(with: ["validityView": validityView]) + [
            view.centerYAnchor.constraint(equalTo: validityView.centerYAnchor),
            validityView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: Layout.validityViewHeightRatio)
        ]
        constraints.activate()
        
        return view
    }()
    
    lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, validityContainer])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.embed(headerStackView, insets: Layout.headerInset)
        return view
    }()
    
    // MARK: - Values
    lazy var primaryValuesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .bottom
        stackView.distribution = .fill
        stackView.spacing = Layout.valuesSpacing
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var primaryValuesContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(primaryValuesStackView)
        
        [
            "V:|[stackView]|",
            "H:|-(insetLR)-[stackView]-(>=0)-|"
        ].constraints(with: ["stackView": primaryValuesStackView], metrics: ["insetLR": Layout.cardInsetLeftRight])
            .activate()
        
        return view
    }()
    
    lazy var secondaryValuesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .bottom
        stackView.distribution = .fill
        stackView.spacing = Layout.valuesSpacing
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var secondaryValuesContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(secondaryValuesStackView)
        
        [
            "V:|[stackView]|",
            "H:|-(>=0)-[stackView]-(insetLR)-|"
        ].constraints(with: ["stackView": secondaryValuesStackView], metrics: ["insetLR": Layout.cardInsetLeftRight])
            .activate()
        
        return view
    }()
    
    // MARK: - Background
    lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - User Interactopm
    private lazy var tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
    private var callback: Callback?
    
    // MARK: - Layout
    private func setupLayout() {
        clipsToBounds = false
        
        layer.borderColor = Style.Border.color.cgColor
        layer.borderWidth = Style.Border.width
        
        layer.shadowOffset = Style.Shadow.offset
        layer.shadowRadius = Style.Shadow.radius
        layer.shadowColor = Style.Shadow.color.cgColor
        layer.shadowOpacity = Style.Shadow.opacity
        
        // Must define cornerRadius on both the background and the views layer
        backgroundImage.layer.masksToBounds = true
        backgroundImage.layer.cornerRadius = Layout.cardCornerRadius
        layer.cornerRadius = Layout.cardCornerRadius
        
        embed(backgroundImage)
        addSubview(headerContainer)
        addSubview(primaryValuesContainer)
        addSubview(secondaryValuesContainer)
        
        let constraints = [
            "H:|[header]|",
            "H:|[primaryContainer]-(containerSpacing)-[secondaryContainer]|",
            
            "V:|[header]",
            "V:[header]-(containerTop)-[primaryContainer]-(containerBottom)-|",
            "V:[header]-(containerTop)-[secondaryContainer]-(containerBottom)-|"
        ].constraints(
            with: [
                "header": headerContainer,
                "primaryContainer": primaryValuesContainer,
                "secondaryContainer": secondaryValuesContainer],
            metrics: [
                "containerSpacing": Layout.valuesContainerSpacing,
                "containerTop": Layout.valuesTopSpacing,
                "containerBottom": Layout.valuesBottomSpacing]) + [
            widthAnchor.constraint(equalTo: heightAnchor, multiplier: Layout.walletCardWidthHeightRatio),
            headerContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: Layout.walletCardHeaderHeightRatio),
            primaryValuesContainer.widthAnchor.constraint(equalTo: secondaryValuesContainer.widthAnchor)
        ]
        constraints.activate()
        
        addGestureRecognizer(tapRecognizer)
    }
    
    func configure(with walletData: WalletCardModel) {
        let expiryInterval = walletData.expiryDate.timeIntervalSinceNow
        validityView.configure(expires: expiryInterval)
        
        titleLabel.attributedText = walletData.title.styledAs(.walletCardTitle).color(walletData.textStyle.color)
        headerContainer.backgroundColor = walletData.headerBackgroundColor
        
        backgroundImage.isHidden = true
        switch walletData.background {
        case .color(let color): backgroundColor = color
        case .namedImage(let identifier):
            backgroundImage.isHidden = false
            backgroundImage.setImage(identifiedBy: identifier)
        case .storedImage(let url):
            backgroundImage.isHidden = false
            backgroundImage.image = UIImage(contentsOfFile: url.path)
        }
        
        primaryValuesStackView.removeArrangedSubviews()
        primaryValuesStackView.addArrangedSubview(UIView()) // Placeholder-View to compensate distribution
        walletData.primaryValues.forEach {
            let valueView = WalletValueView()
            primaryValuesStackView.addArrangedSubview(valueView)
            
            valueView.configure(value: $0, textStyle: walletData.textStyle)
            valueView.widthAnchor.constraint(equalTo: primaryValuesStackView.widthAnchor).isActive = true
        }
        
        secondaryValuesStackView.removeArrangedSubviews()
        secondaryValuesStackView.addArrangedSubview(UIView()) // Placeholder-View to compensate distribution
        walletData.secondaryValues.forEach {
            let valueView = WalletValueView()
            secondaryValuesStackView.addArrangedSubview(valueView)
            
            valueView.configure(value: $0, textStyle: walletData.textStyle)
            valueView.widthAnchor.constraint(equalTo: primaryValuesStackView.widthAnchor).isActive = true
        }
    }
    
    @objc
    dynamic private func cardTapped(_ sender: UITapGestureRecognizer) {
        callback?(self)
    }
    
    // MARK: Lifecycle
    init(callback: Callback? = nil) {
        super.init(frame: .zero)
        self.callback = callback
        setupLayout()
    }
    
    convenience init(with walletData: WalletCardModel, callback: Callback? = nil) {
        self.init(callback: callback)
        self.configure(with: walletData)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    convenience init?(with walletData: WalletCardModel, callback: Callback? = nil, coder: NSCoder) {
        self.init(coder: coder)
        self.callback = callback
        self.configure(with: walletData)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
}
