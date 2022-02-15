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
        static let itemHeaderHeight: CGFloat = 60
        static let itemRelativeWidth: CGFloat = 327
        static let itemRelativeHeight: CGFloat = 207.5
        
        static let itemHeightWidthRatio: CGFloat = itemRelativeHeight / itemRelativeWidth
        static let itemBodyHeightRatio: CGFloat = (itemRelativeHeight - itemHeaderHeight) / itemRelativeHeight
        static let itemVOffsetRatio: CGFloat = itemHeightWidthRatio * itemBodyHeightRatio * -1
        
        static let collectionViewEstimatedCellHeight: NSCollectionLayoutDimension = .fractionalWidth(itemHeightWidthRatio)
        static let collectionViewEstimatedSupplementaryHeight: NSCollectionLayoutDimension = .estimated(50)
        
        static let scrollViewVerticalInset: CGFloat = 4
    }
}

/// Simple container view that wraps the content displayed when wallet entries are available
class ContentWalletView: UIView {
    fileprivate typealias Layout = Constants.Layouts
    
    /// Used to store the calculated UIStackView spacing when layouting the `contentStackViews` elements
    /// This avoids having to re-calculate the offset whenever the scrollview triggers a bounce or similar events that need this value
    private var stackSpacing: CGFloat = 0.0
    
    /// Delegate that forwards `addDocument(:_)` calls from the `AddDocumentSupplementaryView`
    weak var delegate: AddDocumentDelegate? {
        get { addDocumentView.delegate }
        set { addDocumentView.delegate = newValue }
    }
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.contentMode = .scaleToFill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    lazy var contentScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.isExclusiveTouch = true
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.alwaysBounceHorizontal = false
        scrollView.contentInset = .init(top: Layout.itemEdgeSpacing, left: 0, bottom: Layout.itemEdgeSpacing, right: 0)
        return scrollView
    }()
    
    lazy var addDocumentView = AddDocumentButtonView()
    private var openWalletCard: WalletCardView?
    
    private func setupLayout() {
        embed(contentScrollView, insets: .init(top: 0, left: Layout.scrollViewVerticalInset, bottom: 0, right: Layout.scrollViewVerticalInset))
        contentScrollView.embed(contentStackView)
        
        [
            contentStackView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor)
        ].activate()
    }
    
    private func updateLayout() {
        stackSpacing = contentScrollView.frame.width * Layout.itemVOffsetRatio
        contentStackView.spacing = stackSpacing
    }
    
    private func toggleWalletCard(_ card: WalletCardView) {
        defer {
            contentScrollView.scrollRectToVisible(card.frame, animated: true)
        }
        // Note: Find better way to validate if "button View" is the cards successor, hence we dont want to unfold here
        guard contentStackView.arrangedSubviews.firstIndex(of: card) != contentStackView.arrangedSubviews.count - 2 else {
            return
        }
        
        openWalletCard.map { contentStackView.setCustomSpacing(stackSpacing, after: $0) }
        guard card != openWalletCard else {
            openWalletCard = nil
            return
        }
        
        openWalletCard = card
        contentStackView.setCustomSpacing(Layout.itemEdgeSpacing, after: card)
    }
    
    func update(walletData: [WalletCardModel]) {
        contentStackView.removeArrangedSubviews()
        walletData.enumerated().forEach { [toggleWalletCard] in
            let walletView = WalletCardView(with: $0.element, offset: $0.offset, callback: toggleWalletCard)
            contentStackView.addArrangedSubview(walletView)
            
            [
                walletView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
                walletView.heightAnchor.constraint(equalTo: walletView.widthAnchor, multiplier: Layout.itemHeightWidthRatio)
            ].activate()
        }
        
        if let lastView = contentStackView.arrangedSubviews.last {
            contentStackView.setCustomSpacing(0, after: lastView)
        }
        addDocumentView.layer.zPosition = CGFloat(walletData.endIndex)
        contentStackView.addArrangedSubview(addDocumentView)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
}

fileprivate extension WalletCardView {
    convenience init(with walletData: WalletCardModel, offset: Int, callback: @escaping WalletCardView.Callback) {
        self.init(with: walletData, callback: callback)
        layer.zPosition = CGFloat(offset)
    }
}
