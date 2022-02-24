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
    enum Styles {
        static let titleFont: UIFont = .plexSansBold(26.0)
        static let color: UIColor = .white
        static let backgroundColor: UIColor = .primaryBlue
        static let imageAlpha: CGFloat = 0.05
    }

    enum Layout {
        static let logoCenterYMultiplier = 0.8
    }
    enum Texts {
        static let title = "ID Wallet"
    }
}

fileprivate extension ImageNameIdentifier {
    static let background = ImageNameIdentifier(rawValue: "BackgroundPinEntry")
    static let splash = ImageNameIdentifier(rawValue: "SplashLogo")
}

final class BackgroundViewController: BaseViewController {

    lazy var backgroundImageView: UIImageView = {
        let result = UIImageView(identifiedBy: .background)

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = "background"

        result.contentMode = .scaleAspectFill
        result.clipsToBounds = true

        return result
    }()

    lazy var splashLogoImageView: UIImageView = {
        let result = UIImageView(identifiedBy: .splash)

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = "splash"

        result.contentMode = .scaleAspectFit
        result.alpha = Constants.Styles.imageAlpha

        return result
    }()

    lazy var titleLabel: UILabel = {
        let result = UILabel()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = "title"

        result.text = Constants.Texts.title
        result.font = Constants.Styles.titleFont
        result.textColor = Constants.Styles.color
        result.alpha = Constants.Styles.imageAlpha
        result.textAlignment = .center

        return result
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.preferredStatusBarStyle = .lightContent

        view.addSubview(backgroundImageView)
        backgroundImageView.frame = view.frame
        view.addSubview(splashLogoImageView)
        view.addSubview(titleLabel)
        view.sendSubviewToBack(backgroundImageView)

        let views = [
            "background": backgroundImageView,
            "title": titleLabel
        ]

        [
            "V:[title]-104-|"
        ].constraints(with: views).activate()

        [
            // center X
            splashLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // position vertically
            NSLayoutConstraint(
                item: splashLogoImageView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: Constants.Layout.logoCenterYMultiplier,
                constant: 1),
            // resize image to 1/3 of screen width
            NSLayoutConstraint(
                item: splashLogoImageView,
                attribute: .width,
                relatedBy: .equal,
                toItem: view,
                attribute: .width,
                multiplier: 1.0 / 3,
                constant: 0)
        ].activate()
    }
}
