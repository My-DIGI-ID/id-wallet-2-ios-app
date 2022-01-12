//
//  NumberPad.swift
//  IDWallet
//
//  Created by Michael Utech on 02.12.21.
//

import UIKit

// MARK: - Configuration

extension NumberPad {
  struct Style {
    static let regular = NumberPad.Style(.main)

    let themeContext: ThemeContext
    let letters: [String: String]
    let layout: Layout
    let keyViewStyle: NumberPadKey.Style

    init(
      _ themeContext: ThemeContext,
      letters: [String: String] = [
        "2": "ABC",
        "3": "DEF",
        "4": "GHI",
        "5": "JKL",
        "6": "MNO",
        "7": "PQRS",
        "8": "TUV",
        "9": "WXYZ"
      ],
      layout: Layout = Layout.regular,
      keyViewStyle: NumberPadKey.Style? = nil
    ) {
      self.themeContext = themeContext
      self.letters = letters
      self.layout = layout
      if let keyViewStyle = keyViewStyle {
        self.keyViewStyle = keyViewStyle
      } else {
        self.keyViewStyle = NumberPadKey.Style(themeContext)
      }
    }
  }

  struct Layout {
    static let regular = Layout(
      hPadding: 0,
      vPadding: 0,
      hSpacing: 16,
      vSpacing: 0
    )
    static let compressed = Layout(
      hPadding: 0,
      vPadding: 0,
      hSpacing: 20,
      vSpacing: 0
    )

    let hPadding: Int?
    let vPadding: Int?
    let hSpacing: Int?
    let vSpacing: Int?

    var metrics: [String: Any] {
      return [
        "hPadding": hPadding as Any,
        "vPadding": vPadding as Any,
        "hSpacing": hSpacing as Any,
        "vSpacing": vSpacing as Any
      ]
    }
  }
}

@objc protocol NumberPadDelegate {
  @objc optional func numberPad(_ numberPad: NumberPad, didAddDigit: String)
  @objc optional func numberPadDidRemoveLastDigit(_ numberPad: NumberPad)
}

class NumberPad: UIView {
  // configuration
  var style: Style = .regular {
    didSet {
      DispatchQueue.main.async {
        self.setNeedsUpdateStyles()
        self.updateStylesIfNeeded()
      }
    }
  }

  weak var delegate: NumberPadDelegate?

  // controlled subviews and constraints (weakly held)
  private var controlledConstraints = NSHashTable<NSLayoutConstraint>.weakObjects()
  private var keyViewsByName: [String: UIControl] = [:]
  private var contentView: UIStackView!

  // State
  var canAddDigit: Bool = false {
    didSet {
      for number in 0...9 {
        if let control = keyViewsByName["k\(number)"] {
          control.isEnabled = canAddDigit
        }
      }
    }
  }

  var canRemoveLastDigit: Bool = false {
    didSet {
      keyViewsByName["deleteKey"]?.isEnabled = canRemoveLastDigit
      setNeedsUpdateStyles()
      updateStylesIfNeeded()
    }
  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  required init(style: NumberPad.Style = .regular) {
    super.init(frame: CGRect.zero)

    setup(style)
  }

  // MARK: - Setup

  private var _needsUpdateStyles = false

  private func setNeedsUpdateStyles() {
    _needsUpdateStyles = true
  }

  private func updateStylesIfNeeded() {
    if _needsUpdateStyles {
      if keyViewsByName.count >= 10 {
        for number in 0...9 {
          if let keyView = keyViewsByName["k\(number)"] as? NumberPadKey {
            keyView.style = style.keyViewStyle
          }
        }
        _needsUpdateStyles = false
      }
      if let deleteKey = keyViewsByName["deleteKey"] as? UIButton {
        style.themeContext.applyLinkButtonStyles(button: deleteKey)
      }
    }
  }

  // swiftlint:disable function_body_length
  private func setup(_ style: NumberPad.Style) {
    reset()
    self.style = style

    tintColor = self.style.keyViewStyle.themeContext.colors.tintColor

    var size = CGSize.zero
    var sizedViews: [UIView] = []
    var spacerViews: [UIView] = []

    func maxSz(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
      return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
    }

    func makeNumberPadKey(number: Int) -> NumberPadKey {
      let viewName = "k\(number)"
      let key = "\(number)"
      let secondary = style.letters[key]
      let result = NumberPadKey(key, withSecondaryKeys: secondary ?? "", style: style.keyViewStyle)
      keyViewsByName[viewName] = result
      size = maxSz(size, maxSz(result.frame.size, result.intrinsicContentSize))
      sizedViews.append(result)
      result.addTarget(self, action: #selector(didTapNumberKey(sender:)), for: .touchUpInside)
      result.translatesAutoresizingMaskIntoConstraints = false
      return result
    }

    func deleteKey() -> UIView {
      let result = UIButton.systemButton(
        with: UIImage(systemName: "delete.backward")!,
        target: self,
        action: #selector(didTapDeleteKey(sender:))
      )
      result.accessibilityIdentifier = "Key_Delete"
      keyViewsByName["deleteKey"] = result

      size = maxSz(size, maxSz(result.frame.size, result.intrinsicContentSize))
      result.frame.size = size
      result.translatesAutoresizingMaskIntoConstraints = false
      let view = UIView()
      view.addSubview(result)
      view.frame.size = size
      sizedViews.append(view)
      result.makeFillSuperviewConstraints()
      return view
    }

    func placeholer() -> UIView {
      let result = UIView()
      sizedViews.append(result)
      result.translatesAutoresizingMaskIntoConstraints = false
      return result
    }
    func spacer() -> UIView {
      let result = UIView()
      spacerViews.append(result)
      result.translatesAutoresizingMaskIntoConstraints = false
      return result
    }
    func stack() -> UIStackView {
      let result = UIStackView()
      result.translatesAutoresizingMaskIntoConstraints = false
      return result
    }
    func hstack() -> UIStackView {
      let result = stack()
      result.axis = .horizontal
      result.alignment = .firstBaseline
      result.spacing = CGFloat(style.layout.hSpacing ?? 0)
      return result
    }
    func vstack() -> UIStackView {
      let result = stack()
      result.axis = .vertical
      result.alignment = .center
      result.spacing = CGFloat(style.layout.vSpacing ?? 0)
      return result
    }

    contentView = vstack()
    addSubview(contentView)

    var rows = [UIStackView]()

    for rowIndex in 0...2 {
      let rowStack = hstack()
      rows.append(rowStack)

      rowStack.addArrangedSubview(spacer())
      for number in 1...3 {
        let keyView = makeNumberPadKey(number: number + rowIndex * 3)
        rowStack.addArrangedSubview(keyView)
      }
      rowStack.addArrangedSubview(spacer())
      contentView.addArrangedSubview(rowStack)
    }
    let lastRow = hstack()
    rows.append(lastRow)
    lastRow.addArrangedSubview(spacer())
    lastRow.addArrangedSubview(placeholer())
    lastRow.addArrangedSubview(makeNumberPadKey(number: 0))
    lastRow.addArrangedSubview(deleteKey())
    lastRow.addArrangedSubview(spacer())
    contentView.addArrangedSubview(lastRow)

    sizedViews.forEach {
      $0.makeOrUpdateSizeConstraints(
        size: size, priority: .required)
    }
    spacerViews.forEach {
      $0.makeOrUpdateSizeConstraints(
        size: CGSize(width: 0, height: size.height), priority: .required)
    }
  }
  // swiftlint:enable function_body_length

  private func reset() {
    for view in keyViewsByName.values {
      view.removeFromSuperview()
    }
    keyViewsByName.removeAll()

    for constraint in controlledConstraints.allObjects {
      constraint.isActive = false
      if let first = constraint.firstItem {
        first.removeConstraint(constraint)
      }
      if let second = constraint.secondItem {
        second.removeConstraint(constraint)
      }
    }
    controlledConstraints.removeAllObjects()
  }
}

// MARK: - Actions

extension NumberPad {
  @objc func didTapDeleteKey(sender: UIButton) {
    delegate?.numberPadDidRemoveLastDigit?(self)
  }

  @objc func didTapNumberKey(sender: NumberPadKey) {
    delegate?.numberPad?(self, didAddDigit: sender.primaryKey)
  }
}

// MARK: - Layout

extension NumberPad {
  /// Sets up constraints if controlledConstraints is empty
  override func updateConstraints() {
    if controlledConstraints.count >= 4 {
      // Constraints already set up
      return
    }

    guard keyViewsByName.count >= 10 else {
      // Sub views not present, need setup
      // (we're not supporting storyboard setup or init(frame) yet)
      super.updateConstraints()
      // Logging
      return
    }

    var constraints: [NSLayoutConstraint] = []
    contentView.translatesAutoresizingMaskIntoConstraints = false
    let views: [String: UIView] = ["contentView": contentView]
    constraints.append(
      contentsOf: NSLayoutConstraint.constraints(
        withVisualFormat: "H:|-[contentView]-|",
        options: .alignAllFirstBaseline,
        metrics: nil, views: views)
    )
    constraints.append(
      contentsOf: NSLayoutConstraint.constraints(
        withVisualFormat: "V:|-[contentView]-|",
        options: .alignAllFirstBaseline,
        metrics: nil, views: views)
    )
    for constraint in constraints {
      constraint.isActive = true
      controlledConstraints.add(constraint)
    }

    super.updateConstraints()
  }

  /// This view will not work using autoresizing
  override final class var requiresConstraintBasedLayout: Bool { return true }

  /// Uses the (primary) key label for baseline alignment
  override var forFirstBaselineLayout: UIView { return keyViewsByName["4"] ?? self }

  /// Uses the (primary) key label for baseline alignment
  override var forLastBaselineLayout: UIView { return keyViewsByName["6"] ?? self }
}
