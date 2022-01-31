//
//  EmptyWalletViewController.swift
//  IDWallet
//
//  Created by Michael Utech on 19.01.22.
//

import UIKit

class EmptyWalletViewController: BareBaseViewController {

    lazy var headerContainer: UIView = {
        let headerContainer = UIView()
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.accessibilityIdentifier = "header"
        view.addSubview(headerContainer)
        return headerContainer
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.accessibilityIdentifier = "title"
        titleLabel.font = .plexSansBold(25)
        titleLabel.textColor = .black
        titleLabel.text = NSLocalizedString("Deine Dokumente", comment: "")
        headerContainer.addSubview(titleLabel)
        return titleLabel
    }()

    lazy var userIcon: UIImageView = {
        let userIcon = UIImageView()
        userIcon.translatesAutoresizingMaskIntoConstraints = false
        userIcon.accessibilityIdentifier = "userIcon"
        userIcon.image = .requiredImage(name: "ImageIconUser")
        headerContainer.addSubview(userIcon)
        return userIcon
    }()

    lazy var contentContainer: UIView = {
        let contentContainer = UIView()
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.accessibilityIdentifier = "content"
        view.addSubview(contentContainer)
        return contentContainer
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = "image"
        imageView.image = .requiredImage(name: "ImageEmptyWalletPage")
        contentContainer.addSubview(imageView)
        return imageView
    }()

    lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.accessibilityIdentifier = "message"
        messageLabel.font = .plexSans(17)
        messageLabel.textColor = .appGrey1
        messageLabel.text = NSLocalizedString("Die Wallet ist leer.\nFüge dein erstes Dokument hinzu.", comment: "")
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textAlignment = .center
        contentContainer.addSubview(messageLabel)
        return messageLabel
    }()

    lazy var addDocumentButton: UIButton = {
        let addDocumentButton = UIButton()
        addDocumentButton.translatesAutoresizingMaskIntoConstraints = false
        addDocumentButton.accessibilityIdentifier = "addDocument"
        addDocumentButton.setImage(.init(systemName: "plus"), for: .normal)
        addDocumentButton.setTitle(NSLocalizedString("Dokument hinzufügen", comment: ""), for: .normal)
        addDocumentButton.titleLabel?.font = .plexSansBold(15)
        addDocumentButton.tintColor = .white
        addDocumentButton.backgroundColor = .appMainBackground
        addDocumentButton.layer.cornerRadius = 30.0
        view.addSubview(addDocumentButton)
        return addDocumentButton
    }()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(style: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0),
            contentContainer.topAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: 20.0),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24.0),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24.0),
            addDocumentButton.topAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: 20.0),
            addDocumentButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60.0),
            addDocumentButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60.0),
            // The placement of the button in sketch seems to be too high, in most other places primary
            // action buttons are placed 60pts above bottom. Did that here too, cf. w/ design team
            addDocumentButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40.0),
            addDocumentButton.heightAnchor.constraint(equalToConstant: 60.0)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            userIcon.topAnchor.constraint(greaterThanOrEqualTo: headerContainer.topAnchor),
            userIcon.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor),
            userIcon.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor),
            userIcon.bottomAnchor.constraint(greaterThanOrEqualTo: headerContainer.bottomAnchor),
            userIcon.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            // Instead of using a fixed vertical placement, content should be v-centered allowing for
            // more flexibility on different screen sizes. General solution because this occurs rather
            // often.
            imageView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 100.0),
            // The placement of the image and relative views is a bit hacky because of the dimensions
            // of the SVG (due to rotated background triangle). Needs adjustment and cleanup when the
            // image is finalized.
            imageView.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor, constant: 75.0),
            messageLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -120.0),
            messageLabel.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 40.0),
            messageLabel.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -40.0),
            messageLabel.bottomAnchor.constraint(greaterThanOrEqualTo: contentContainer.bottomAnchor, constant: -80.0)
        ])
   }
}
