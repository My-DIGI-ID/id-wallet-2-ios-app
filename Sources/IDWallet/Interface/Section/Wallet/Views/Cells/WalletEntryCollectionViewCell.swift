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

final class WalletEntryCollectionViewCell: UICollectionViewCell {
    
    lazy var dummyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private func setupView() {
        backgroundColor = .clear
        
        // FIXME [12/31/2022]: iOS 14 has a bug where Cells require UIView-Encapsulated-Layout-Height/Width, causing a Constraint Error
        embed(dummyLabel,
              insets: .init(top: 10, left: 8, bottom: 10, right: 8),
              priorities: .init(bottom: .init(rawValue: 999), right: .init(rawValue: 999)))
    }

    func configure(with walletData: WalletCardModel, at: IndexPath) {
        dummyLabel.text = walletData.title
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
