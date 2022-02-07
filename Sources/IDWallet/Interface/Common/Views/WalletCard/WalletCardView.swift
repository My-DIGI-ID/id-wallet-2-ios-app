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

class WalletCardView: UIView {
    
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
            "H:|[validityView]|",
        ].constraints(with: ["validityView": validityView]) + [
            view.centerYAnchor.constraint(equalTo: validityView.centerYAnchor),
            validityView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 24 / 60)
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
        view.embed(headerStackView, insets: .init(top: 0, left: 16, bottom: 0, right: 16))
        return view
    }()
    
    // MARK: - Values
    lazy var primaryValuesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .bottom
        stackView.distribution = .equalCentering
        stackView.spacing = 10
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var primaryValuesContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(primaryValuesStackView)
        
        [
            "V:|[stackView]|",
            "H:|-(16)-[stackView]-(>=0)-|"
        ].constraints(with: ["stackView": primaryValuesStackView])
            .activate()
        
        return view
    }()
    
    lazy var secondaryValuesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .bottom
        stackView.distribution = .equalCentering
        stackView.spacing = 10
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var secondaryValuesContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(secondaryValuesStackView)
        
        [
            "V:|[stackView]|",
            "H:|-(>=0)-[stackView]-(16)-|"
        ].constraints(with: ["stackView": secondaryValuesStackView])
            .activate()
        
        return view
    }()
    
    private func setupLayout() {
        clipsToBounds = true
        layer.cornerRadius = 16
        
        addSubview(headerContainer)
        addSubview(primaryValuesContainer)
        addSubview(secondaryValuesContainer)
        
        let constraints = [
            "H:|[header]|",
            "H:|[primaryContainer]-(15)-[secondaryContainer]|",
            
            "V:|[header]",
            "V:[header]-(8)-[primaryContainer]-(13)-|",
            "V:[header]-(8)-[secondaryContainer]-(13)-|",
        ].constraints(with: ["header": headerContainer,
                             "primaryContainer": primaryValuesContainer,
                             "secondaryContainer": secondaryValuesContainer]) + [
                                
            widthAnchor.constraint(equalTo: heightAnchor, multiplier: 366 / 232),
            headerContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 60 / 232),
            primaryValuesContainer.widthAnchor.constraint(equalTo: secondaryValuesContainer.widthAnchor)
        ]
        constraints.activate()
    }
    
    func configure(with walletData: WalletCardModel) {
        titleLabel.text = walletData.title // TODO: Format
        headerContainer.backgroundColor = walletData.headerBackgroundColor
        
        validityView.configure(expires: walletData.expiryDate.timeIntervalSinceNow)
        
        switch walletData.background {
        case .color(let color): backgroundColor = color
        case .namedImage(let identifier): break // TODO
        case .storedImage(let url): break // TODO
        }
        
        primaryValuesStackView.removeArrangedSubviews()
        primaryValuesStackView.addArrangedSubview(UIView()) // Placeholder-View to compensate distribution
        walletData.primaryValues.forEach {
            let valueView = WalletValueView()
            primaryValuesStackView.addArrangedSubview(valueView)
            valueView.configure(value: $0)
        }
        
        secondaryValuesStackView.removeArrangedSubviews()
        secondaryValuesStackView.addArrangedSubview(UIView()) // Placeholder-View to compensate distribution
        walletData.secondaryValues.forEach {
            let valueView = WalletValueView()
            secondaryValuesStackView.addArrangedSubview(valueView)
            valueView.configure(value: $0)
        }
    }
    
    // MARK: Lifecycle
    init() {
        super.init(frame: .zero)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
    }
}
