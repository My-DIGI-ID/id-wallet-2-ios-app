/*
 * Copyright 2021 Bundesrepublik Deutschland
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

import UIKit

fileprivate extension ImageNameIdentifier {
    static let userIcon = ImageNameIdentifier(rawValue: "ImageIconUser")
}

final class WalletViewController: BareBaseViewController {
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var userIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.setImage(identifiedBy: .userIcon)
        
        [
            image.widthAnchor.constraint(equalToConstant: 32),
            image.heightAnchor.constraint(equalToConstant: 32),
        ].activate()
        
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
        return view
    }()
    
    lazy var contentWalletView: ContentWalletView = {
        let view = ContentWalletView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @objc dynamic func addDoumentButtonPressed(_ sender: UIControl) {
        // TODO: Handle Add Document
    }
    
    // MARK: - Lifecycle
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported. Use init() instead")
    }

    init() {
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Layout
        view.backgroundColor = .white
        view.addSubview(headerContainer)
        view.addSubview(contentContainer)
        
        let constraints = [
            "H:|-(24)-[header]-(24)-|",
            "H:|-(24)-[content]-(24)-|",
            "V:|-(60)-[header]-(5)-[content]|",
        ].constraints(with: ["header": headerContainer, "content": contentContainer]) + [
            userIcon.widthAnchor.constraint(equalToConstant: 32),
            userIcon.heightAnchor.constraint(equalToConstant: 32),
        ]
            
        constraints.activate()
        
        headerLabel.font = .plexSansBold(25)
        headerLabel.textColor = .black
        headerLabel.text = NSLocalizedString("Deine Dokumente", comment: "")
        
        noContentWalletView.addDocumentButton.addTarget(self, action: #selector(addDoumentButtonPressed(_:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Check if wallet entries available
        let hasWalletEntries = true
        
        if !hasWalletEntries {
            contentWalletView.removeFromSuperview()
            contentContainer.addSubview(noContentWalletView)
            let constraints = [
                "H:|[content]|",
            ].constraints(with: ["header": headerContainer, "content": noContentWalletView]) + [
                contentContainer.centerYAnchor.constraint(equalTo: noContentWalletView.centerYAnchor)
            ]
            constraints.activate()
        } else {
            noContentWalletView.removeFromSuperview()
            contentContainer.embed(contentWalletView)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
