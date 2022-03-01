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

import CocoaLumberjackSwift
import UIKit

// MARK: - Configuration
private enum Constants {
    enum Styles {
        static let backgroundColor: UIColor = .white
        static let pageIndicatorTintColor: UIColor = .grey3
        static let currentPageIndicatorTintColor: UIColor = .primaryBlue
    }
    
    enum Layout {
        static let verticalSpacing = 40.0
        static let verticalTextSpacing = 18.0
        static let horizontalTextPadding = 30.0

        static let minImageWidth = 220.0
        static let minImageHeight = 240.0

        static let contentStackViewInset: UIEdgeInsets = .init(
            top: 0,
            left: horizontalTextPadding,
            bottom: 0,
            right: horizontalTextPadding
        )
    }
}

final class OnboardingPageViewController: BaseViewController {
    fileprivate typealias Styles = Constants.Styles
    fileprivate typealias Layout = Constants.Layout
    
    private let viewModel: ViewModel
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.accessibilityIdentifier = ViewID.imageView.key
        imageView.image = viewModel.image

        [
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor), // ratio 1:1
        ].activate()
        
        return imageView
    }()
    
    lazy var headingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = ViewID.headingLabel.key
        label.text = viewModel.heading
        label.font = .plexSansBold(25)
        label.textColor = .black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    lazy var subHeadingLabel: ScrollableTextView = {
        let textView = ScrollableTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.accessibilityIdentifier = ViewID.subHeadingLabel.key
        textView.label.text = viewModel.subHeading
        textView.label.font = .plexSans(17)
        textView.label.textColor = .grey1
        textView.label.lineBreakMode = .byWordWrapping
        textView.label.textAlignment = .center
        return textView
    }()
    
    lazy var textWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = ViewID.textWrapper.key
        view.addSubview(headingLabel)
        view.addSubview(subHeadingLabel)
        
        [
            "H:|[heading]|",
            "H:|[subHeading]|",
            "V:|[heading]-(textspc)-[subHeading]|",
        ].constraints(
            with: ["heading": headingLabel, "subHeading": subHeadingLabel],
            metrics: ["textspc": Layout.verticalTextSpacing]
        ).activate()

        return view
    }()
    
    lazy var imageWrapper: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.accessibilityIdentifier = ViewID.imageWrapper.key
        view.addSubview(imageView)
        
        let constraints = [
            "V:|[img]|",
        ].constraints(
            with: ["img": imageView]
        ) + [
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ]
        
        constraints.activate()
        
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageWrapper, textWrapper])
        stackView.accessibilityIdentifier = ViewID.stackView.key
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Layout.verticalTextSpacing
        return stackView
    }()
    
    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported. Use init(viewModel:completion:) instead")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Styles.backgroundColor
        view.embed(stackView, insets: Layout.contentStackViewInset)

        let size = imageView.image?.size ?? CGSize.zero
        let aspectRatio = size.width / size.height

        [
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: aspectRatio),
            imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.Layout.minImageWidth),
            imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.Layout.minImageHeight)
        ].activate()
    }
}

extension OnboardingPageViewController {
    enum ViewID: String, BaseViewID {
        case imageWrapper
        case textWrapper
        case imageView
        case headingLabel
        case subHeadingLabel
        case stackView
        
        var key: String { return rawValue }
    }
    
    class ViewModel {
        let image: UIImage?
        let heading: String
        let subHeading: String
        init(image: UIImage?, heading: String, subHeading: String) {
            self.image = image
            self.heading = heading
            self.subHeading = subHeading
        }
    }
}
