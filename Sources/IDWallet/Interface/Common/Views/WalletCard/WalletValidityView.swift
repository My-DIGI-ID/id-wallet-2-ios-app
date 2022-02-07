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

/// This view displays an info-text informing the user about the expiration state of the wallet-card.
/// 
/// If less than 15h remain, this View will hightlight in Yellow and show a corresponding text.
/// If the card expired, this view will highlight in white and show a corresponding text.
/// In any other case, the background stays clear and no text is displayed
class WalletValidityView: UIView {
    
    lazy var validityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func updateCornerRadius() {
        layer.cornerRadius = bounds.height / 2
    }
    
    private func setupLayout() {
        updateCornerRadius()
        backgroundColor = .white
        embed(validityLabel, insets: .init(top: 3, left: 6, bottom: 3, right: 10))
    }
    
    func configure(expires milliSeconds: Double ) {
        
        if milliSeconds <= 0 { // Expired
            validityLabel.text = NSLocalizedString("Ungültig", comment: "") // TODO: Font
            backgroundColor = .white
        } else if milliSeconds <= 900000 { // 15 Minutes remaining
            validityLabel.text = NSLocalizedString("Noch 15h gültig", comment: "") // TODO: Font
            backgroundColor = .highlightYellow
        } else {
            validityLabel.text = ""
            backgroundColor = .clear
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
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
