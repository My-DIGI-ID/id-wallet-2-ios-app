//
//  Rounded.swift
//  IDWallet
//
//  Created by Michael Utech on 13.12.21.
//

import UIKit

@IBDesignable
class Rounded: UIView {

  @IBInspectable var fillColor: UIColor? {
    didSet { update() }
  }
  @IBInspectable var strokeColor: UIColor? {
    didSet { update() }
  }

  @IBInspectable var strokeWidth: CGFloat = 0 {
    didSet { update() }
  }

  @IBInspectable var width: CGFloat = -1 {
    didSet { update() }
  }

  @IBInspectable var height: CGFloat = -1 {
    didSet { update() }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    fillColor = tintColor
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    strokeWidth = coder.decodeDouble(forKey: "strokeWidth")
    strokeColor = coder.decodeObject(forKey: "strokeColor") as? UIColor
    fillColor = coder.decodeObject(forKey: "fillColor") as? UIColor
    width = coder.decodeDouble(forKey: "width")
    height = coder.decodeDouble(forKey: "height")
  }
  override func encode(with coder: NSCoder) {
    super.encode(with: coder)
    coder.encode(width, forKey: "width")
    coder.encode(height, forKey: "height")
    if let fillColor = fillColor {
      coder.encode(fillColor, forKey: "fillColor")
    }
    if let strokeColor = strokeColor {
      coder.encode(strokeColor, forKey: "strokeColor")
    }
    coder.encode(strokeWidth, forKey: "strokeWidth")
  }
  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: width >= 0 ? width : size.width,
      height: height >= 0 ? height : size.height)
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    update()
  }

  func update() {
    let size = layer.frame.size
    let cornerRadius = min(size.height, size.width) / 2
    layer.cornerRadius = cornerRadius

    layer.borderWidth = strokeWidth
    layer.borderColor = strokeColor?.cgColor ?? UIColor.clear.cgColor
    layer.backgroundColor = fillColor?.cgColor ?? tintColor.cgColor
  }
}
