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
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var validityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var headerContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, validityView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    private func setupLayout() {
        addSubview(headerContainer)
        
        let constraints = [
            "H:|-(16)-[header]-(16)-|",
            "V:|[header]",
        ].constraints(with: ["header": headerContainer]) + [
            widthAnchor.constraint(equalTo: heightAnchor, multiplier: 366 / 230),
            headerContainer.heightAnchor.constraint(equalToConstant: 60),
        ]
        constraints.activate()
        
        backgroundColor = .primaryBlue
        clipsToBounds = true
        layer.cornerRadius = 16
    }
    
    func configure(with walletData: WalletCardModel) {
        titleLabel.text = walletData.title
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
