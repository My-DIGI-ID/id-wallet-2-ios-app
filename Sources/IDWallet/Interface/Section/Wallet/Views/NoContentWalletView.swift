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
        static let infoTextStyle: AttributedStyle = .walletInfoText
    }
    
    enum Layouts {
        static let emptyWalletImageAspectRatio: CGFloat = 1.0
        static let emptyWalletImageRelativeWidth: CGFloat = 0.7
        static let contentStackviewSpacing: CGFloat = 30
        static let documentButtonInset: UIEdgeInsets = .init(top: 0, left: 20, bottom: 0, right: 20)
    }
}

fileprivate extension ImageNameIdentifier {
    static let emptyWalletIcon = ImageNameIdentifier(rawValue: "ImageEmptyWalletPage")
    static let systemPlus = ImageNameIdentifier(rawValue: "plus")
}

/// Simple container view that wraps the content displayed when no wallet entries are available
class NoContentWalletView: UIView {
    fileprivate typealias Style = Constants.Styles
    fileprivate typealias Layout = Constants.Layouts
    
    /// Delegate that forwards `addDocument(:_)` calls from the addDocumentButton
    weak var delegate: AddDocumentDelegate?
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.contentMode = .scaleToFill
        stackView.backgroundColor = .clear
        stackView.spacing = Layout.contentStackviewSpacing
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
            emptyWalletImageView.widthAnchor.constraint(equalTo: emptyWalletImageView.heightAnchor, multiplier: Layout.emptyWalletImageAspectRatio),
            emptyWalletImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Layout.emptyWalletImageRelativeWidth),
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
        let button = WalletButton(titleText: NSLocalizedString("Dokument hinzufügen", comment: ""),
                                  image: .init(systemId: .systemPlus),
                                  imageAlignRight: false,
                                  style: .primary,
                                  primaryAction: .init { [weak self] _ in
            self?.delegate?.addDocument()
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var addDocumentButtonContainer: UIView = {
        let view = UIView()
        view.embed(addDocumentButton, insets: Layout.documentButtonInset)
        return view
    }()
    
    private func setupLayout() {
        
        addSubview(contentStackView)
        let constraints = [
            "H:|[stackView]|"
        ].constraints(with: ["stackView": contentStackView]) + [
            contentStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        constraints.activate()
        
        contentStackView.addArrangedSubview(emptyWalletContainer)
        contentStackView.addArrangedSubview(infoTextLabel)
        contentStackView.addArrangedSubview(addDocumentButtonContainer)
        
        infoTextLabel.attributedText = NSLocalizedString("Die Wallet ist leer.\nFüge Dein erstes Dokument hinzu.", comment: "").styledAs(Style.infoTextStyle)
        
        [
            emptyWalletContainer.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            addDocumentButtonContainer.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
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
