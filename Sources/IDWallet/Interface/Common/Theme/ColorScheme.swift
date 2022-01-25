//
//  Colors.swift
//  IDWallet
//
//  Created by Michael Utech on 07.12.21.
//

import UIKit

// MARK: - Custom Color Assignments

extension UIColor {

  // Main Colors (white on blue/violet-ish background)

  static var appMainBackground: UIColor {
    requiredColor(named: "AppMainBackground")
  }

  static var appMainGradientStart: UIColor {
    requiredColor(named: "AppMainGradientStart")
  }

  static var appMainGradientEnd: UIColor {
    requiredColor(named: "AppMainGradientEnd")
  }

  static var appMainText: UIColor {
    requiredColor(named: "AppMainText")
  }

  static var appMainTextSecondary: UIColor {
    requiredColor(named: "AppMainTextSecondary")
  }

  static var appMainTint: UIColor {
    requiredColor(named: "AppMainTint")
  }

  static var appMainTintContrast: UIColor {
    requiredColor(named: "AppMainTintContrast")
  }

  static var appMainTintInactive: UIColor {
    requiredColor(named: "AppMainTintInactive")
  }

  static var appMainTintInactiveContrast: UIColor {
    requiredColor(named: "AppMainTintInactiveContrast")
  }

  // Alternative 1 (blue/violet-ish on white background)

  static var appAlt1Background: UIColor {
    requiredColor(named: "AppAlt1Background")
  }

  static var appAlt1GradientStart: UIColor? {
    UIColor(named: "AppAlt1GradientStart")
  }

  static var appAlt1GradientEnd: UIColor? {
    UIColor(named: "AppAlt1GradientEnd")
  }

  static var appAlt1Text: UIColor {
    requiredColor(named: "AppAlt1Text")
  }

  static var appAlt1TextSecondary: UIColor {
    requiredColor(named: "AppAlt1TextSecondary")
  }

  static var appAlt1Tint: UIColor {
    requiredColor(named: "AppAlt1Tint")
  }

  static var appAlt1TintContrast: UIColor {
    requiredColor(named: "AppAlt1TintContrast")
  }

  static var appAlt1TintInactive: UIColor {
    requiredColor(named: "AppAlt1TintInactive")
  }

  static var appAlt1TintInactiveContrast: UIColor {
    requiredColor(named: "AppAlt1TintInactiveContrast")
  }    

  private static var disabledAlpha: CGFloat {
    return 100 / 255
  }
}

struct ColorScheme: Equatable {
  struct Gradient: Equatable {
    static func == (lhs: ColorScheme.Gradient, rhs: ColorScheme.Gradient) -> Bool {
      return
        (lhs.gradientType == rhs.gradientType && lhs.colors == rhs.colors
        && lhs.startPoint == rhs.startPoint && lhs.endPoint == rhs.endPoint)
    }
    let gradientType: CAGradientLayerType
    let colors: [UIColor]
    let startPoint: CGPoint
    let endPoint: CGPoint
  }
  static var main = ColorScheme(
    preferredStatusBarStyle: .lightContent,
    backgroundColor: .white,
    backgroundGradient: Gradient(
      gradientType: .axial,
      colors: [
        UIColor.gradientStart,
        UIColor.gradientEnd
      ],
      startPoint: CGPoint(x: 0, y: 0),
      endPoint: CGPoint(x: 0, y: 1000)
    ),
    textColor: .walBlack,
    textSecondaryColor: .grey1,
    tintColor: .primaryBlue,
    tintContrastColor: .white,
    tintInactiveColor: .grey4,
    tintInactiveContrastColor: .grey2
  )
  static var alternative = ColorScheme(
    preferredStatusBarStyle: .darkContent,
    backgroundColor: .white,
    textColor: .black,
    textSecondaryColor: .grey1,
    tintColor: .primaryBlue,
    tintContrastColor: .white,
    tintInactiveColor: .grey4,
    tintInactiveContrastColor: .grey2
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
