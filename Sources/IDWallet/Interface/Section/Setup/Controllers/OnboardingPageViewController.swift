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
        static let horizontalTextPadding = 24.0
        static let horizontalImageMargin = 17.0
    }
}

final class OnboardingPageViewController: BareBaseViewController {
    fileprivate typealias Styles = Constants.Styles
    fileprivate typealias Layout = Constants.Layout
    
    private let viewModel: ViewModel
    
    lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.imageView.key
        result.image = viewModel.image
        return result
    }()
    
    lazy var headingLabel: UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.headingLabel.key
        result.text = viewModel.heading
        result.font = .plexSansBold(25)
        result.textColor = .black
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    lazy var subHeadingLabel: UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.subHeadingLabel.key
        result.text = viewModel.subHeading
        result.font = .plexSans(17)
        result.textColor = .black
        result.numberOfLines = 0
        result.lineBreakMode = .byWordWrapping
        result.textAlignment = .center
        return result
    }()
    
    lazy var textWrapper: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.textWrapper.key
        result.addSubview(headingLabel)
        result.addSubview(subHeadingLabel)
        
        [
            "H:|[heading]|",
            "H:|[subHeading]|",
            "V:|[heading]-(textspc)-[subHeading]-(>=0)-|",
        ].constraints(
            with: ["heading": headingLabel, "subHeading": subHeadingLabel],
            metrics: ["textspc": Layout.verticalTextSpacing]
        ).activate()
        
        return result
    }()
    
    lazy var imageWrapper: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.imageWrapper.key
        result.addSubview(imageView)
        
        let constraints = [
            "V:|[img]|",
            "H:|-(==margin)-[img]-(==margin)-|",
        ].constraints(
            with: ["img": imageView],
            metrics: ["margin": Layout.horizontalImageMargin]
        ) + [
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor), // ratio 1:1
        ]
        
        constraints.activate()
        
        return result
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageWrapper, textWrapper])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = Layout.verticalTextSpacing
        return stackView
    }()
    
    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(style: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported. Use init(viewModel:completion:) instead")
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Styles.backgroundColor
        view.embed(stackView, insets: .init(top: 0, left: Layout.horizontalTextPadding, bottom: 0, right: Layout.horizontalTextPadding))
        
        [
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
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
