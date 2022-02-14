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
        static let cellBackground: UIColor = .white
        static let alphaExpired: CGFloat = 0.8
        static let alphaValid: CGFloat = 1.0
    }
    
    enum Layouts {
        static let cardCornerRadius: CGFloat = 16
    }
}

final class WalletEntryCollectionViewCell: UICollectionViewCell {
    fileprivate typealias Style = Constants.Styles
    fileprivate typealias Layout = Constants.Layouts
    
    lazy var walletCard: WalletCardView = {
        let view = WalletCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private func setupView() {
        backgroundColor = Style.cellBackground
        clipsToBounds = true
        layer.cornerRadius = Layout.cardCornerRadius
        
        // FIXME [12/31/2022]: iOS 14 has a bug where Cells require UIView-Encapsulated-Layout-Height/Width, causing a Constraint Error
        // Workaround is to lower the priority just one below `required`
        embed(
            walletCard, priorities: .init(
                bottom: .init(rawValue: 999),
                right: .init(rawValue: 999)))
    }
    
    func configure(with walletData: WalletCardModel, at: IndexPath) {
        walletCard.configure(with: walletData)
        walletCard.alpha = walletData.expiryDate.timeIntervalSinceNow <= 0 ? Style.alphaExpired : Style.alphaValid
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
}
