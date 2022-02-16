//
//  UIColorExtensions.swift
//  IDWallet
//
//  Created by Michael Utech on 07.12.21.
//

import CoreGraphics
import UIKit

// MARK: - Conversions between UIColor and hex strings
extension UIColor {
    // MARK: - Mandatory Colors from Assets
    static func requiredColor(named: String) -> UIColor {
        // Explicitly providing the bundle to ensure UI tests can access styles (which in turn
        // require access to asset colors).
        guard let result = UIColor(named: named, in: Bundle(for: CustomFontLoader.self), compatibleWith: nil) else {
            ContractError.missingColor(named).fatal()
        }
        return result
    }
}
