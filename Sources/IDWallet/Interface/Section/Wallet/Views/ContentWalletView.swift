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
    enum Layouts {
        static let itemEdgeSpacing: CGFloat = 30
        static let itemWidthToHeightRatio: CGFloat = 207.5 / 327
        static let collectionViewEstimatedCellHeight: NSCollectionLayoutDimension = .fractionalWidth(itemWidthToHeightRatio)
        static let collectionViewEstimatedSupplementaryHeight: NSCollectionLayoutDimension = .estimated(50)
    }
}

/// Simple container view that wraps the content displayed when wallet entries are available
class ContentWalletView: UIView {
    fileprivate typealias Layout = Constants.Layouts
    
    // MARK: CollectionView
    private typealias Section = Int
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    private typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Row>
     
    private struct Row: Hashable, Equatable {
        let indexPath: IndexPath
        let content: WalletCardModel
    }
    
    /// Delegate that forwards `addDocument(:_)` calls from the `AddDocumentSupplementaryView`
    weak var delegate: AddDocumentDelegate?
    
    private lazy var dataSource: DataSource = {
        let walletCardCell = UICollectionView.CellRegistration<WalletEntryCollectionViewCell, WalletCardModel> {
//            $0.delegate = self // TODO: Interaction Delegate for Card Details
            $0.configure(with: $2, at: $1)
        }
        
        let dataSource = DataSource(collectionView: walletCollectionView) {
            return $0.dequeueConfiguredReusableCell(using: walletCardCell, for: $1, item: $2.content)
        }
        
        let footerRegistration = UICollectionView
            .SupplementaryRegistration<AddDocumentSupplementaryView>(elementKind: UICollectionView.elementKindSectionFooter) { [weak self] (supplementView, _, _) in
            guard let self = self else { return }
            supplementView.delegate = self.delegate
        }
        
        dataSource.supplementaryViewProvider = {
            guard $1 == UICollectionView.elementKindSectionFooter else { return nil }
            return $0.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: $2)
        }
        
        return dataSource
    }()
    
    lazy var walletCollectionView: UICollectionView = {
        let layout: UICollectionViewLayout = {
            let layoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: Layout.collectionViewEstimatedCellHeight)
            let layoutItem = NSCollectionLayoutItem(layoutSize: layoutSize)
            layoutItem.edgeSpacing = .init(leading: nil, top: .fixed(Layout.itemEdgeSpacing), trailing: nil, bottom: nil)
            
            let supplementaryView = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                                  heightDimension: Layout.collectionViewEstimatedSupplementaryHeight),
                                                                                elementKind: UICollectionView.elementKindSectionFooter,
                                                                                alignment: .bottom)
            supplementaryView.zIndex = 2
            supplementaryView.pinToVisibleBounds = true
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: layoutSize, subitems: [layoutItem])
            let layoutSection = NSCollectionLayoutSection(group: group)
            layoutSection.boundarySupplementaryItems = [supplementaryView]
            
            return UICollectionViewCompositionalLayout(section: layoutSection)
        }()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private func setupLayout() {
        embed(walletCollectionView)
        dataSource.apply(.init())
    }
    
    func update(walletData: [WalletCardModel]) {
        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(walletData.enumerated().map {
            .init(indexPath: .init(row: $0.offset, section: 0), content: $0.element)
        },
                             toSection: 0)
        
        dataSource.apply(snapshot, animatingDifferences: true)
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
