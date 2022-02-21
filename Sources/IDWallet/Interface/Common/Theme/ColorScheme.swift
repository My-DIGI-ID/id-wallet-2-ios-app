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

// MARK: - Custom Color Assignments
extension UIColor {
    private static var disabledAlpha: CGFloat {
        return 100 / 255
    }
}

struct ColorScheme: Equatable {
    struct Gradient: Equatable {
        static func == (lhs: ColorScheme.Gradient, rhs: ColorScheme.Gradient) -> Bool {
            return (
                lhs.gradientType == rhs.gradientType &&
                lhs.colors == rhs.colors &&
                lhs.startPoint == rhs.startPoint &&
                lhs.endPoint == rhs.endPoint
            )
        }
        let gradientType: CAGradientLayerType
        let colors: [UIColor]
        let startPoint: CGPoint
        let endPoint: CGPoint
    }
    static var main = ColorScheme(
        preferredStatusBarStyle: .lightContent,
        backgroundColor: .appMainBackground,
        backgroundGradient: Gradient(
            gradientType: .axial,
            colors: [
                UIColor.appMainGradientStart,
                UIColor.appMainGradientEnd
            ],
            startPoint: CGPoint(x: 0, y: 0),
            endPoint: CGPoint(x: 0, y: 1000)
        ),
        textColor: .appMainText,
        textSecondaryColor: .appMainTextSecondary,
        tintColor: .appMainTint,
        tintContrastColor: .appMainTintContrast,
        tintInactiveColor: .appMainTintInactive,
        tintInactiveContrastColor: .appMainTintInactiveContrast
    )
    static var alternative = ColorScheme(
        preferredStatusBarStyle: .darkContent,
        backgroundColor: .appAlt1Background,
        textColor: .appAlt1Text,
        textSecondaryColor: .appAlt1TextSecondary,
        tintColor: .appAlt1Tint,
        tintContrastColor: .appAlt1TintContrast,
        tintInactiveColor: .appAlt1TintInactive,
        tintInactiveContrastColor: .appAlt1TintInactiveContrast
    )
    let preferredStatusBarStyle: UIStatusBarStyle
    let backgroundColor: UIColor
    let backgroundGradient: Gradient?
    let textColor: UIColor
    let textSecondaryColor: UIColor
    let tintColor: UIColor
    let tintContrastColor: UIColor
    let tintInactiveColor: UIColor
    let tintInactiveContrastColor: UIColor
    init(
        preferredStatusBarStyle: UIStatusBarStyle,
        backgroundColor: UIColor,
        backgroundGradient: Gradient? = nil,
        textColor: UIColor,
        textSecondaryColor: UIColor,
        tintColor: UIColor,
        tintContrastColor: UIColor,
        tintInactiveColor: UIColor,
        tintInactiveContrastColor: UIColor
    ) {
        self.preferredStatusBarStyle = preferredStatusBarStyle
        self.backgroundColor = backgroundColor
        self.backgroundGradient = backgroundGradient
        self.textColor = textColor
        self.textSecondaryColor = textSecondaryColor
        self.tintColor = tintColor
        self.tintContrastColor = tintContrastColor
        self.tintInactiveColor = tintInactiveColor
        self.tintInactiveContrastColor = tintInactiveContrastColor
    }
    
    func setupBackgroundGradient(_ view: UIView) {
        if let gradient = backgroundGradient {
            view.withGradientLayer { gradientLayer in
                gradientLayer.frame.size = view.frame.size
                gradientLayer.type = .axial
                gradientLayer.colors = gradient.colors.map { $0.cgColor }
                gradientLayer.startPoint = gradient.startPoint
                gradientLayer.endPoint = gradient.endPoint
            }
        }
    }
}
