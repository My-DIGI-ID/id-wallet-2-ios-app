//
//  UIColorExtensions.swift
//  IDWallet
//
//  Created by Michael Utech on 07.12.21.
//

import UIKit

// MARK: - Conversions between UIColor and hex strings

extension UIColor {
  convenience init?(hexString: String?) {
    let input: String! = (hexString ?? "")
      .replacingOccurrences(of: "#", with: "")
      .uppercased()
    var alpha: CGFloat = 1.0
    var red: CGFloat = 0
    var blue: CGFloat = 0
    var green: CGFloat = 0
    switch input.count {
    case 3:  // #RGB
      red = Self.colorComponent(from: input, start: 0, length: 1)
      green = Self.colorComponent(from: input, start: 1, length: 1)
      blue = Self.colorComponent(from: input, start: 2, length: 1)
    case 4:  // #ARGB
      alpha = Self.colorComponent(from: input, start: 0, length: 1)
      red = Self.colorComponent(from: input, start: 1, length: 1)
      green = Self.colorComponent(from: input, start: 2, length: 1)
      blue = Self.colorComponent(from: input, start: 3, length: 1)
    case 6:  // #RRGGBB
      red = Self.colorComponent(from: input, start: 0, length: 2)
      green = Self.colorComponent(from: input, start: 2, length: 2)
      blue = Self.colorComponent(from: input, start: 4, length: 2)
    case 8:  // #AARRGGBB
      alpha = Self.colorComponent(from: input, start: 0, length: 2)
      red = Self.colorComponent(from: input, start: 2, length: 2)
      green = Self.colorComponent(from: input, start: 4, length: 2)
      blue = Self.colorComponent(from: input, start: 6, length: 2)
    default:
      NSException.raise(
        NSExceptionName("Invalid color value"),
        format:
          "Color value \"%@\" is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB",
        arguments: getVaList([hexString ?? ""]))
    }
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }

  var hexString: String? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    let multiplier = CGFloat(255.999999)

    guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
      return nil
    }

    if alpha == 1.0 {
      return String(
        format: "#%02lX%02lX%02lX",
        Int(red * multiplier),
        Int(green * multiplier),
        Int(blue * multiplier)
      )
    } else {
      return String(
        format: "#%02lX%02lX%02lX%02lX",
        Int(red * multiplier),
        Int(green * multiplier),
        Int(blue * multiplier),
        Int(alpha * multiplier)
      )
    }
  }
  static func colorComponent(from string: String!, start: Int, length: Int) -> CGFloat {
    let substring = (string as NSString)
      .substring(with: NSRange(location: start, length: length))
    let fullHex = length == 2 ? substring : "\(substring)\(substring)"
    var hexComponent: UInt64 = 0
    Scanner(string: fullHex)
      .scanHexInt64(&hexComponent)
    return CGFloat(Double(hexComponent) / 255.0)
  }
}

// MARK: - Mandatory Colors from Assets

extension UIColor {
  static func requiredColor(named: String) -> UIColor {
    // Explicitly providing the bundle to ensure UI tests can access styles (which in turn
    // require access to asset colors).
    let bundle = Bundle(for: CustomFontLoader.self)
    if let result = UIColor(named: named, in: bundle, compatibleWith: nil) {
      return result
    }

    ContractError.missingColor(named).fatal()
  }
}
