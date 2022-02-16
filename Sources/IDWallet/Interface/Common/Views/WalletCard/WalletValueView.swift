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

fileprivate extension AttributedStyle {
    static var walletCardValueTitle: AttributedStyle = .init([.foregroundColor: UIColor.walBlack,
                                                    .font: UIFont.plexSansBold(12)])
    
    static var walletCardValue: AttributedStyle = .init([.foregroundColor: UIColor.walBlack,
                                                    .font: UIFont.plexSans(12)])
}


/// Represents a key-value pair (primary or secondary) of a Wallet-Card
/// Title and Value are arranged in vertival order and aligned to the left
class WalletValueView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }()
    
    private func setupLayout() {
        embed(stackView)
    }
    
    func configure(value: WalletCardModel.WalletValue, textStyle: WalletCardModel.TextStyle) {
        titleLabel.attributedText = value.title.styledAs(.walletCardValueTitle).color(textStyle.color)
        valueLabel.attributedText = value.value.styledAs(.walletCardValue).color(textStyle.color)
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
