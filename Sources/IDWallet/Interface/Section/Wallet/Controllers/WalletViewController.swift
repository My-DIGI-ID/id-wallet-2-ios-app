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

final class WalletViewController: BareBaseViewController {
    
    // MARK: CollectionView
    private typealias Section = Int
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Row>
     
    private struct Row: Hashable, Equatable {
        let indexPath: IndexPath
        let content: WalletCardModel
    }
    
    private lazy var dataSource: DataSource = {
        
        // TODO: Remove empty cell - placeholder only
        let emptyCell = UICollectionView.CellRegistration<UICollectionViewCell, NSNull> { _, _, _ in }
        
        let dataSource = DataSource(collectionView: walletCollectionView) {
            
            // TODO: Remove - placeholder only
            switch $2.indexPath.row {
            default:
                return $0.dequeueConfiguredReusableCell(using: emptyCell, for: $1, item: nil)
            }
        }
        // TODO: Configure DataSource
        return dataSource
    }()
    
    lazy var walletCollectionView: UICollectionView = {
        // TODO: Make collectionViewLayout
    
        let collection = UICollectionView(frame: .zero)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .clear
        return collection
    }()
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var userIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = .requiredImage(name: "ImageIconUser") // TODO: Replace with named-image
        
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
    
    lazy var emptyContentView: EmptyWalletView = {
        let view = EmptyWalletView()
//        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
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
        // TODO: Layout
        view.backgroundColor = .white
        view.addSubview(headerContainer)
        
        let constraints = [
            "H:|-(24)-[header]-(24)-|",
            "V:|-(60)-[header]",
        ].constraints(with: ["header": headerContainer]) + [
            userIcon.widthAnchor.constraint(equalToConstant: 32),
            userIcon.heightAnchor.constraint(equalToConstant: 32),
        ]
            
        constraints.activate()
        
        headerLabel.font = .plexSansBold(25)
        headerLabel.textColor = .black
        headerLabel.text = NSLocalizedString("Deine Dokumente", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Check if wallet entries available
        
        view.addSubview(emptyContentView)
        [
            "H:|-(24)-[content]-(24)-|",
            "V:[header]-(5)-[content]-(>=0)-|"
        ].constraints(with: ["header": headerContainer, "content": emptyContentView]).activate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
