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
    static let systemPlus = ImageNameIdentifier(rawValue: "plus")
}

protocol AddDocumentDelegate: AnyObject {
    func addDocument()
}

final class AddDocumentButtonView: UIView {
    
    weak var delegate: AddDocumentDelegate?
    
    lazy var addDocumentButton: WalletButton = {
        let button = WalletButton(
            titleText: "\(NSLocalizedString("Dokument hinzufügen", comment: ""))",
            image: .init(systemId: .systemPlus),
            imageAlignRight: false,
            style: .secondary,
            primaryAction: .init { [weak self] _ in
            self?.delegate?.addDocument()
        })
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private func setupLayout() {
        embed(addDocumentButton, insets: .init(top: 30, left: 20, bottom: 0, right: 20))
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
