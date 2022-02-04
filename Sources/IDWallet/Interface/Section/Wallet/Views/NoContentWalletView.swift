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

fileprivate extension ImageNameIdentifier {
    static let emptyWalletIcon = ImageNameIdentifier(rawValue: "ImageEmptyWalletPage")
}

/// Simple container view that wraps the content displayed when no wallet entries are available
class NoContentWalletView: UIView {
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.contentMode = .scaleToFill
        stackView.backgroundColor = .clear
        stackView.spacing = 30
        return stackView
    }()
    
    lazy var emptyWalletImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setImage(identifiedBy: .emptyWalletIcon)
        return imageView
    }()
    
    lazy var emptyWalletContainer: UIView = {
        let view = UIView()
        view.addSubview(emptyWalletImageView)
        
        let constraints = [
            "V:|[image]|"
        ].constraints(with: ["image": emptyWalletImageView]) + [
            view.centerXAnchor.constraint(equalTo: emptyWalletImageView.centerXAnchor),
            emptyWalletImageView.widthAnchor.constraint(equalTo: emptyWalletImageView.heightAnchor, multiplier: 257 / 279),
            emptyWalletImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
        ]
        constraints.activate()
        
        return view
    }()
    
    lazy var infoTextLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var addDocumentButton: WalletButton = {
        let button = WalletButton(titleText: "\(NSLocalizedString("Dokument hinzufügen", comment: ""))",
                                  image: .init(systemName: "plus"),
                                  imageAlignRight: false,
                                  style: .primary)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var addDocumentButtonContainer: UIView = {
        let view = UIView()
        view.addSubview(addDocumentButton)
        
        let constraints = [
            "V:|[button]|",
        ].constraints(with: ["button": addDocumentButton]) + [
            view.centerXAnchor.constraint(equalTo: addDocumentButton.centerXAnchor),
            addDocumentButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
        ]
        constraints.activate()
        
        return view
    }()
    
    private func setupLayout() {
        
        addSubview(contentStackView)
        let constraints = [
            "H:|[stackView]|",
        ].constraints(with: ["stackView": contentStackView]) + [
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        constraints.activate()
        
        contentStackView.addArrangedSubview(emptyWalletContainer)
        contentStackView.addArrangedSubview(infoTextLabel)
        contentStackView.addArrangedSubview(addDocumentButtonContainer)
        
        // TODO: Font-Format
        infoTextLabel.text = NSLocalizedString("Die Wallet ist leer.\nFüge dein erstes Dokument hinzu.", comment: "")
        infoTextLabel.font = .plexSans(17)
        infoTextLabel.textColor = .appGrey1

        [
            emptyWalletContainer.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            addDocumentButtonContainer.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
        ].activate()
    }
    
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
