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
import Aries

private enum Constants {
    enum Styles {
        static let headerStyle: AttributedStyle = .header
        static let backgroundColor: UIColor = .white
    }
    
    enum Layouts {
        static let userIconSize: CGSize = .init(width: 32, height: 32)
        static let viewInsetLeftRight: CGFloat = 24
        static let topSpacing: CGFloat = 60
        static let contentSpacing: CGFloat = 5
    }
}

fileprivate extension ImageNameIdentifier {
    static let userIcon = ImageNameIdentifier(rawValue: "ImageIconUser")
    
    static let baseIDBackground = ImageNameIdentifier(rawValue: "BaseIDBackground")
    static let ddlBackground = ImageNameIdentifier(rawValue: "DDLBackground")
    static let mesaBackground = ImageNameIdentifier(rawValue: "MesaBackground")
}

final class WalletViewController: BareBaseViewController {
    fileprivate typealias Style = Constants.Styles
    fileprivate typealias Layout = Constants.Layouts
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var userIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.setImage(identifiedBy: .userIcon)
        return image
    }()
    
    lazy var headerContainer: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerLabel, userIcon])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var contentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var noContentWalletView: NoContentWalletView = {
        let view = NoContentWalletView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    lazy var contentWalletView: ContentWalletView = {
        let view = ContentWalletView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    // MARK: - Lifecycle
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported. Use init() instead")
    }
    
    init() {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Style.backgroundColor
        view.addSubview(headerContainer)
        view.addSubview(contentContainer)
        
        let constraints = [
            "H:|-(inset)-[header]-(inset)-|",
            "H:|-(inset)-[content]-(inset)-|",
            "V:|-(topSpace)-[header]-(contentSpace)-[content]|"
        ].constraints(
            with: [
                "header": headerContainer,
                "content": contentContainer],
            metrics: [
                "inset": Layout.viewInsetLeftRight,
                "topSpace": Layout.topSpacing,
                "contentSpace": Layout.contentSpacing]) + [
                    userIcon.widthAnchor.constraint(equalToConstant: Layout.userIconSize.width),
                    userIcon.heightAnchor.constraint(equalToConstant: Layout.userIconSize.height)
                ]
        
        constraints.activate()
        
        headerLabel.attributedText = NSLocalizedString("Deine Dokumente", comment: "").styledAs(Style.headerStyle)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task(priority: .userInitiated) {
            let credentialService = CustomCredentialService()
            let credentials = try await credentialService.credentials()
            
            if credentials.isEmpty {
                self.contentWalletView.removeFromSuperview()
                self.contentContainer.embed(self.noContentWalletView)
            } else {
                self.noContentWalletView.removeFromSuperview()
                self.contentContainer.embed(self.contentWalletView)
                
                let models = credentials.map { credential in
                    WalletCardModel(
                        id: "MESAID",
                        background: .namedImage(.mesaBackground),
                        title: "MESA Mitarbeiter",
                        primaryValues: [
                            .init(
                                title: "Name",
                                value: (credential.attributes.first { $0.name == "Vorname" }?.value.first.map { "\($0). " } ?? "")
                                + (credential.attributes.first { $0.name == "Nachname" }?.value ?? "")
                            )
                        ],
                        secondaryValues: [
                            .init(title: "Gültig bis", value: "9. März 22")
                        ],
                        expiryDate: .init(timeIntervalSinceNow: 2_259_000) // 60 * 60 * 24 * 30 => 30 days in seconds
                    )
                }
                
                self.contentWalletView.update(
                    walletData: models
                )
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}

extension WalletViewController: AddDocumentDelegate {
    func addDocument() {
        // TODO: Trigger add Document here
        print("Add Document")
    }
}
