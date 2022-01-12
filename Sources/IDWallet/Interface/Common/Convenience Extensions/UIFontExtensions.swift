//
//  UIFontExtensions.swift
//  IDWallet
//
//  Created by Michael Utech on 07.12.21.
//

import CocoaLumberjackSwift
import UIKit

enum CustomFontRegistrationError: Error, AppError {
  case readDataFailed(_ url: URL)
  case createDataProviderFailed(_ url: URL)
  case createFontFromDataProviderFailed(_ url: URL)
  case registerFontFailed(_ url: URL, fontName: String?, cause: Error? = nil)

  var title: String {
    "Custom Font Registration Error"
  }

  var problem: String {
    switch self {
    case .readDataFailed:
      return NSLocalizedString(
        "Failed to read font file", comment: "error message")
    case .createDataProviderFailed:
      return NSLocalizedString(
        "Failed to create data provider for font data", comment: "error message")
    case .createFontFromDataProviderFailed:
      return NSLocalizedString(
        "Failed to create font from data", comment: "error message")
    case .registerFontFailed:
      return NSLocalizedString(
        "Failed to register font", comment: "error message")
    }
  }
  var details: String {
    switch self {
    case .readDataFailed(let url):
      return String.localizedStringWithFormat(
        NSLocalizedString(
          "%s [%s]",
          comment: "readDataFailed(problem, font URL)"),
        problem, url.absoluteString
      )
    case .createDataProviderFailed(let url):
      return String.localizedStringWithFormat(
        NSLocalizedString(
          "%s in [%s]",
          comment: "createDataProviderFailed(problem, font URL)"),
        problem, url.absoluteString
      )
    case .createFontFromDataProviderFailed(let url):
      return String.localizedStringWithFormat(
        NSLocalizedString(
          "%s in [%s]",
          comment: "createFontFromDataProviderFailed(problem, font URL)"),
        url.absoluteString
      )
    case .registerFontFailed(let url, let fontName, let cause):
      return cause == nil
        ? String.localizedStringWithFormat(
          NSLocalizedString(
            "%s [%s] from data in [%s]",
            comment: "registerFontFailed(problem, font name, font URL)"),
          fontName ?? "", url.absoluteString
        )
        : String.localizedStringWithFormat(
          NSLocalizedString(
            "%s [%s] from data in [%s]: reason given [%s]",
            comment: "registerFontFailed(problem, font name, font URL, cause)"),
          fontName ?? "", url.absoluteString, cause!.localizedDescription
        )
    }
  }
}

class CustomFontLoader {
  private static let loadableFontFileExtensions: [String] = [
    "ttf"
  ]

  private static var fontFileURLs = fontFileURLsInBundle(Bundle(for: CustomFontLoader.self))

  private static func fontFileURLsInBundle(_ bundle: Bundle) -> [URL] {
    if let urls = try? FileManager.default.contentsOfDirectory(
      at: bundle.bundleURL,
      includingPropertiesForKeys: [],
      options: .skipsHiddenFiles
    ) {
      return urls.filter {
        loadableFontFileExtensions.contains($0.pathExtension.lowercased())
      }
    }
    return []
  }
  /// See `requiredFont`code comments  below for how and why to use this method
  static func registerCustomFonts() throws {
    var errors: [Error] = []
    for url in fontFileURLs {
      guard let data = NSData(contentsOf: url) else {
        errors.append(CustomFontRegistrationError.readDataFailed(url))
        continue
      }
      guard let provider = CGDataProvider(data: data) else {
        errors.append(CustomFontRegistrationError.createDataProviderFailed(url))
        continue
      }
      guard let font = CGFont(provider) else {
        errors.append(CustomFontRegistrationError.createFontFromDataProviderFailed(url))
        continue
      }
      var errorRef: Unmanaged<CFError>?
      if !CTFontManagerRegisterGraphicsFont(font, &errorRef) {
        errors.append(
          CustomFontRegistrationError.registerFontFailed(
            url,
            fontName: font.fullName == nil ? nil : String(font.fullName! as NSString),
            cause: errorRef?.takeRetainedValue()
          ))
      }
    }
    if let error = MultipleErrors.from(errors) {
      throw error
    }
  }
}

extension UIFont {
  static func requiredFont(name: String, size: CGFloat) -> UIFont {
    if let result = UIFont(name: name, size: size) {
      return result
    }
    // If the font is actually available, we might still reach this point when UI testing,
    // because UI testing apparently does not preserve the App as separate bundle and
    // UIFont does not find fonts even if they are available in the UI test bundle.
    // Most annoying...
    do {
      // We need to load all custom fonts, because the file name often does not match
      // the font name. The performance hit should not be of concern, because UIFont finds
      // fonts on its own in the App context (though it probably does the same thing). This is
      // why we should avoid adding all available Plex variations and stick to those we actually use.
      try CustomFontLoader.registerCustomFonts()
    } catch {
      DDLogWarn(error)
    }
    // At this point the font should be registered if the font really is available.
    if let result = UIFont(name: name, size: size) {
      return result
    }
    // If this fails, make sure that the required font file exists, is not corrupted and has a
    // target membership for your product (including your test project if the error occurs during
    // tests). This is a fatal error because we decide which fonts we use, not some circumstances.
    // Also, if this was not a fatal error, `registerCustomFonts` would be called repeatedly for
    // failures which would be bad (log pollution + performance and bad style, pun intended)
    ContractError.missingFont(name, size: size).fatal()
  }
}
