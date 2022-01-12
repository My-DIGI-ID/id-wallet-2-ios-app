//
//  NumberPadKeyView.swift
//  IDWallet
//
//  Created by Michael Utech on 01.12.21.
//

// swiftlint:disable file_length

import UIKit

// MARK: - Configuration
// MARK: -

extension NumberPadKey {
  enum ViewID: BaseViewID {
    case container
    case keyContainer(_ character: Character)
    case key(_ character: Character)
    case secondaryKey(_ text: String)
    case deleteKey
    var key: String {
      switch self {
      case .container:
        return "NumberPadContainer"
      case .keyContainer(let character):
        return "NumberPadKeyContainer_\(character)"
      case .key(let character):
        return "NumberPadKey_\(character)"
      case .secondaryKey(let text):
        return "NumberPadKey_\(text)"
      case .deleteKey:
        return "NumberPadKey_Delete"
      }
    }
  }

  /// Parameters affecting the appearance of key views and their layout
  struct Style {

    let themeContext: ThemeContext

    let layout: Layout

    let touchAnimationDuration: CGFloat

    static let regular = Style(.main)

    init(
      _ themeContext: ThemeContext,
      layout: Layout? = nil,
      touchAnimationDuration: CGFloat = 0.25
    ) {
      self.themeContext = themeContext
      self.layout =
        layout
        ?? (UIScreen.main.bounds.size.height < 750
          ? .compressed
          : .regular)
      self.touchAnimationDuration = touchAnimationDuration
    }

    fileprivate func applyTo(_ view: NumberPadKey) {
      view.primaryKeyLabel.font = themeContext.typography.numberPadFont
      view.secondaryKeysLabel.font = themeContext.typography.numberPadAuxiliaryFont

      if view.isEnabled {
        view.primaryKeyLabel.textColor = themeContext.colors.textColor
        view.secondaryKeysLabel.textColor = themeContext.colors.textSecondaryColor
      } else {
        view.primaryKeyLabel.textColor = themeContext.colors.tintInactiveColor
        view.secondaryKeysLabel.textColor = themeContext.colors.tintInactiveColor
      }
    }
  }
  struct Layout {
    static let regular = Layout(
      hPadding: 20,
      vPadding: 20,
      auxiliarySpacing: -2,
      auxiliaryMinPadding: 10
    )
    static let compressed = Layout(
      hPadding: 20,
      vPadding: 10,
      auxiliarySpacing: -2,
      auxiliaryMinPadding: 10
    )

    /// Autolayout metric defining the horizontal padding between primary label and the container view
    let hPadding: Int

    /// Autolayout metric defining the vertical padding between primary label and the container view
    let vPadding: Int

    /// Autolayout metric defining the vertical spacing between primary and secondary labels
    let auxiliarySpacing: Int

    /// Autolayout metric defining the minimumg padding between secondary label and container view
    let auxiliaryMinPadding: Int

    var metrics: [String: Any] {
      [
        "hPadding": hPadding,
        "vPadding": vPadding,
        "secondarySpacing": auxiliarySpacing,
        "secondaryMinPadding": auxiliaryMinPadding
      ]
    }
  }

  enum TouchState {
    case idle
    case down
// swiftlint:disable identifier_name
    case up
// swiftlint:enable identifier_name
    case cancelled
  }
}

// MARK: - NumberPadKey
// MARK: -

///
/// Key designed to be used by a custom number key pad.
///
/// Displays the primary key label (a number) and optionally secondary key labels (letters).
///
class NumberPadKey: UIControl {

  // MARK: - Storage
  var style: NumberPadKey.Style = .regular {
    didSet {
      DispatchQueue.main.async {
        self.setNeedsUpdateStyles()
        self.updateStylesIfNeeded()
      }
    }
  }
  var primaryKey: String {
    get { primaryKeyLabel.text ?? "" }
    set(value) {
      guard value.count <= 1 else {
        fatalError(
          "Invalid number pad key \(value), expected empty string or a single digit or letter")
      }
      if primaryKeyLabel.text != value {
        setNeedsUpdateStyles()
        primaryKeyLabel.text = value
        self.accessibilityIdentifier = "Key_CodeChar_\(value)"
      }
    }
  }
  var secondaryKeys: String {
    get { secondaryKeysLabel.text ?? "" }
    set(value) {
      if secondaryKeysLabel.text != value {
        setNeedsUpdateStyles()
        secondaryKeysLabel.text = value
      }
    }
  }

  // MARK: State

  override var isEnabled: Bool {
    get { super.isEnabled }
    set(value) {
      if super.isEnabled != value {
        super.isEnabled = value
        setNeedsUpdateStyles()
        updateStylesIfNeeded()
      }
    }
  }

  fileprivate var primaryKeyLabel: UILabel!

  fileprivate var secondaryKeysLabel: UILabel!

  private var controlledConstraints = NSHashTable<NSLayoutConstraint>.weakObjects()

  private var touchState: TouchState = .idle {
    didSet {
      guard touchState != oldValue else { return }

      switch touchState {
      case .idle:
        break
      case .down:
        performTouchDownAnimations()
      case .up:
        performTouchUpAnimations { _ in
          self.touchState = .idle
        }
      case .cancelled:
        performTouchCancelledAnimations { _ in
          self.touchState = .idle
        }
      }
    }
  }

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  convenience init(
    _ primaryKey: String, withSecondaryKeys secondaryKeys: String = "", style: NumberPadKey.Style?
  ) {
    self.init(frame: CGRect.zero)

    self.primaryKey = primaryKey
    self.secondaryKeys = secondaryKeys
    if let style = style {
      self.style = style
    }
  }

  convenience init(_ primaryKey: String, withStyle style: NumberPadKey.Style?) {
    self.init(primaryKey, withSecondaryKeys: "", style: style)
  }

  // MARK: - Setup

  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false

    primaryKeyLabel = UILabel()
    primaryKeyLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(primaryKeyLabel)

    secondaryKeysLabel = UILabel()
    secondaryKeysLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(secondaryKeysLabel)

    setNeedsUpdateStyles()
  }

  // MARK: - Layout

  private var _needsUpdateStyles: Bool = true
  private func setNeedsUpdateStyles() {
    if !_needsUpdateStyles {
      _needsUpdateStyles = true
      setNeedsUpdateConstraints()
    }
  }
  private func updateStylesIfNeeded() {
    if _needsUpdateStyles {
      _needsUpdateStyles = false
      style.applyTo(self)
    }
  }
  private func removeControlledConstraints() {
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
  /// Sets up constraints if controlledConstraints is empty
  override func updateConstraints() {
    removeControlledConstraints()
    updateStylesIfNeeded()
    let views = [
      "container": self,
      "primary": primaryKeyLabel,
      "secondary": secondaryKeysLabel
    ]
    let metrics = style.layout.metrics
    var constraints = [
      primaryKeyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      primaryKeyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    ]
    constraints.append(
      contentsOf: NSLayoutConstraint.constraints(
        withVisualFormat: "H:|-(hPadding@249)-[primary]-(hPadding@249)-|", metrics: metrics,
        views: views as [String: Any])
    )
    constraints.append(
      contentsOf: NSLayoutConstraint.constraints(
        withVisualFormat: "V:|-(vPadding)-[primary]-(vPadding@249)-|", metrics: metrics,
        views: views as [String: Any])
    )

    constraints.append(
      secondaryKeysLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
    )
    constraints.append(
      contentsOf: NSLayoutConstraint.constraints(
        withVisualFormat:
          "V:[primary]-(secondarySpacing)-[secondary]-(>=secondaryMinPadding@251)-|",
        metrics: metrics, views: views as [String: Any]))

    for constraint in constraints {
      constraint.isActive = true
      controlledConstraints.add(constraint)
    }

    super.updateConstraints()
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(
      width: (CGFloat(style.layout.hPadding * 2)
        + max(
          primaryKeyLabel.intrinsicContentSize.width, secondaryKeysLabel.intrinsicContentSize.width)),
      height: (CGFloat(style.layout.vPadding * 2) + primaryKeyLabel.intrinsicContentSize.height
        + secondaryKeysLabel.intrinsicContentSize.height + CGFloat(style.layout.auxiliarySpacing))
    )
  }
  /// This view will not work using autoresizing
  override final class var requiresConstraintBasedLayout: Bool { return true }
  /// Uses the (primary) key label for alignment
  override func alignmentRect(forFrame frame: CGRect) -> CGRect {
    primaryKeyLabel.alignmentRect(forFrame: frame)
  }
  /// Uses the (primary) key label for alignment
  override func frame(forAlignmentRect alignmentRect: CGRect) -> CGRect {
    primaryKeyLabel.frame(forAlignmentRect: alignmentRect)
  }

  /// Uses the (primary) key label for baseline alignment
  override var forFirstBaselineLayout: UIView { primaryKeyLabel }

  /// Uses the (primary) key label for baseline alignment
  override var forLastBaselineLayout: UIView { primaryKeyLabel }
}

// MARK: Gesture Tracking

extension NumberPadKey {
  private var extendedBounds: CGRect {
    bounds
  }

  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    guard touchState == .idle else { return false }

    let point = touch.location(in: self)
    if extendedBounds.contains(point) {
      touchState = .down
      return true
    } else {
      touchState = .cancelled
      return false
    }
  }
  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let point = touch.location(in: self)
    if extendedBounds.contains(point) {
      touchState = .down
      return true
    } else {
      touchState = .cancelled
      return false
    }
  }
  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    super.endTracking(touch, with: event)
    if let point = touch?.location(in: self), extendedBounds.contains(point) {
      touchState = .up
    } else {
      touchState = .cancelled
    }
  }
  override func cancelTracking(with event: UIEvent?) {
    touchState = .cancelled
  }
}

// MARK: - Animation Support

extension NumberPadKey {
  private func animateLabelTextColor(
    color: UIColor, completion: @escaping (Bool) -> Void = { _ in }
  ) {
    UIView.animate(
      withDuration: self.style.touchAnimationDuration,
      animations: {
        UIView.transition(
          with: self.primaryKeyLabel, duration: self.style.touchAnimationDuration,
          options: .transitionCrossDissolve,
          animations: {
            self.primaryKeyLabel.textColor = color
          }, completion: nil)
        UIView.transition(
          with: self.primaryKeyLabel, duration: self.style.touchAnimationDuration,
          options: .transitionCrossDissolve,
          animations: {
            self.secondaryKeysLabel.textColor = color
          }, completion: nil)
      },
      completion: {
        completion($0)
      })
  }

  private func performTouchDownAnimations(_ completion: @escaping (Bool) -> Void = { _ in }) {
    animateLabelTextColor(
      color: style.themeContext.colors.tintInactiveContrastColor, completion: completion)
  }

  fileprivate func performTouchUpAnimations(_ completion: @escaping (Bool) -> Void = { _ in }) {
    animateLabelTextColor(color: style.themeContext.colors.textColor, completion: completion)
  }

  fileprivate func performTouchCancelledAnimations(
    _ completion: @escaping (Bool) -> Void = { _ in }
  ) {
    animateLabelTextColor(color: style.themeContext.colors.textColor, completion: completion)
  }
}
