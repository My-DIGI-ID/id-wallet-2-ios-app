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
    }
}

extension OnboardingPageViewController {
    enum ViewID: String, BaseViewID {
        case containerView
        case contentWrapper
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

final class OnboardingPageViewController: BareBaseViewController {
    fileprivate typealias Styles = Constants.Styles
    fileprivate typealias Layout = Constants.Layout
    
    private let viewModel: ViewModel
    
    lazy var containerView: AlignmentWrapperView = {
        let result = AlignmentWrapperView()
        self.view.addSubview(result)
        
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.containerView.key
        
        result.horizontalAlignment = .center
        result.verticalAlignment = .center
        
        return result
    }()
    
    lazy var contentWrapper: UIView = {
        let result = UIView()
        self.containerView.arrangedView = result
        
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.contentWrapper.key
        
        return result
    }()
    
    lazy var imageView: UIImageView = {
        let result = UIImageView()
        self.contentWrapper.addSubview(result)
        
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.imageView.key
        
        result.image = viewModel.image
        
        return result
    }()
    
    lazy var headingLabel: UILabel = {
        let result = UILabel()
        self.contentWrapper.addSubview(result)
        
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
        self.contentWrapper.addSubview(result)
        
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
        
        createLayoutConstraints()
    }
    
    // MARK: - Layout
    
    private func createLayoutConstraints() {
        let views: [String: Any] = [
            "container": containerView,
            "image": imageView,
            "heading": headingLabel,
            "subHeading": subHeadingLabel
        ]
        
        let metrics: [String: Any] = [
            "vspc": Layout.verticalSpacing,
            "vspctxt": Layout.verticalTextSpacing,
            "hpadtxt": Layout.horizontalTextPadding
        ]
        
        [
            "H:|-[container]-|",
            "V:|-[container]-|",
            "H:|-(hpadtxt)-[heading]-(hpadtxt)-|",
            "H:|-(hpadtxt)-[subHeading]-(hpadtxt)-|"
        ].constraints(
            with: views, metrics: metrics, options: []
        ).activate()
        
        [
            "V:|-[image]-(vspc)-[heading]-(vspctxt)-[subHeading]-|"
        ].constraints(
            with: views, metrics: metrics, options: .alignAllCenterX
        ).activate()
        
        headingLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            .isActive = true
        
        if let image = imageView.image {
            [
                imageView.heightAnchor.constraint(equalToConstant: image.size.height),
                imageView.widthAnchor.constraint(equalToConstant: image.size.width)
            ].activate()
        }
    }
}
