//
//  UIImageExtensions.swift
//  IDWallet
//
//  Created by Michael Utech on 11.12.21.
//

import UIKit

extension UIImage {
  class func requiredImage(name: String) -> UIImage {
    if let result = UIImage(
      named: name, in: Bundle(for: CustomFontLoader.self), compatibleWith: nil
    ) {
      return result
    }

    // If this fails, make sure that an image set with the specified name exists in Assets.
    ContractError.missingImage(name).fatal()
  }

  func scaledToWidth(width: CGFloat) -> UIImage {
    let scale = width / size.width
    let size = CGSize(width: width, height: scale * size.height)
    return withSize(targetSize: size)
  }

  func scaledToHeight(height: CGFloat) -> UIImage {
    let scale = height / size.height
    let size = CGSize(width: scale * size.width, height: height)
    return withSize(targetSize: size)
  }

  func withSize(targetSize: CGSize) -> UIImage {
    // https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
    let image = self
    let size = image.size

    let widthRatio = targetSize.width / size.width
    let heightRatio = targetSize.height / size.height

    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if widthRatio > heightRatio {
      newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
      newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
    }

    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage!
  }
}
