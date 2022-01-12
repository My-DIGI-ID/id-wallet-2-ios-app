//
//  Layout.swift
//  IDWallet
//
//  Created by Michael Utech on 19.12.21.
//

import Foundation
import UIKit

extension NSLayoutConstraint.Relation {
  var vfl: String {
    switch self {
    case .equal:
      return ""
    case .greaterThanOrEqual:
      return ">="
    case .lessThanOrEqual:
      return "<="
    @unknown default:
      ContractError.unsupportedApiChange("NSLayoutConstraint.Relation.\(self)").fatal()
    }
  }
}

extension UILayoutPriority {
  var vfl: String {
    return "@\(rawValue)"
  }
}

struct LayoutPredicate: CustomStringConvertible, Equatable {
  static func equal(_ constant: CGFloat, priority: UILayoutPriority? = nil) -> LayoutPredicate {
    LayoutPredicate(constant, relation: .equal, priority: priority)
  }
  static func equal(_ constant: CGFloat, _ priority: Float) -> LayoutPredicate {
    return equal(constant, priority: .init(priority))
  }
  static func lessThanOrEqual(_ constant: CGFloat, priority: UILayoutPriority? = nil)
    -> LayoutPredicate {
    LayoutPredicate(constant, relation: .lessThanOrEqual, priority: priority)
  }
  static func lessThanOrEqual(_ constant: CGFloat, _ priority: Float) -> LayoutPredicate {
    return lessThanOrEqual(constant, priority: .init(priority))
  }
  static func greaterThanOrEqual(_ constant: CGFloat, priority: UILayoutPriority? = nil)
    -> LayoutPredicate {
    LayoutPredicate(constant, relation: .greaterThanOrEqual, priority: priority)
  }
  static func greaterThanOrEqual(_ constant: CGFloat, _ priority: Float) -> LayoutPredicate {
    return greaterThanOrEqual(constant, priority: .init(priority))
  }

  let constant: CGFloat
  let relation: NSLayoutConstraint.Relation
  let priority: UILayoutPriority?

  init(
    _ constant: CGFloat, relation: NSLayoutConstraint.Relation = .equal,
    priority: UILayoutPriority? = nil
  ) {
    self.constant = constant
    self.relation = relation
    self.priority = priority
  }

  var description: String {
    return vfl
  }

  var vfl: String {
    return "\(relation.vfl)\(constant)\(priority?.vfl ?? "")"
  }
}

extension Array where Element == LayoutPredicate {

  // Convenience methods allowing you to write ``.equal(4)`` instead of ``[.equal(4)]``

  static func equal(_ constant: CGFloat, priority: UILayoutPriority? = nil) -> [LayoutPredicate] {
    [LayoutPredicate(constant, relation: .equal, priority: priority)]
  }
  static func equal(_ constant: CGFloat, _ priority: Float) -> [LayoutPredicate] {
    equal(constant, priority: .init(priority))
  }
  static func lessThanOrEqual(_ constant: CGFloat, priority: UILayoutPriority? = nil)
    -> [LayoutPredicate] {
    [LayoutPredicate(constant, relation: .lessThanOrEqual, priority: priority)]
  }
  static func lessThanOrEqual(_ constant: CGFloat, _ priority: Float) -> [LayoutPredicate] {
    lessThanOrEqual(constant, priority: .init(priority))
  }
  static func greaterThanOrEqual(_ constant: CGFloat, priority: UILayoutPriority? = nil)
    -> [LayoutPredicate] {
    [LayoutPredicate(constant, relation: .greaterThanOrEqual, priority: priority)]
  }
  static func greaterThanOrEqual(_ constant: CGFloat, _ priority: Float) -> [LayoutPredicate] {
    greaterThanOrEqual(constant, priority: .init(priority))
  }
  /// A VFL (visual format language) representation of the metric.
  ///
  /// ```swift
  /// let metric = Metric(...)
  /// contraints(withVisualFormat: "V:|\(metric.vfl)[someView]"
  /// ```
  var vfl: String? {
    guard !isEmpty else { return nil }
    return "-(\(map { $0.vfl }.joined(separator: ",")))-"
  }
}

struct ViewSize: Equatable {
  let width: [LayoutPredicate]
  let height: [LayoutPredicate]
  init(width: [LayoutPredicate] = [], height: [LayoutPredicate] = []) {
    self.width = width
    self.height = height
  }

  init(width: CGFloat, height: CGFloat? = nil) {
    self.init(width: .equal(width), height: height == nil ? [] : .equal(height!))
  }

  init(height: CGFloat) {
    self.init(width: [], height: .equal(height))
  }

  init(_ size: [LayoutPredicate]) {
    self.width = size
    self.height = size
  }

  init(_ size: CGSize, priority: UILayoutPriority) {
    self.init(
      width: .equal(size.width, priority: priority), height: .equal(size.height, priority: priority)
    )
  }

  init(_ size: CGSize, _ priority: Float = UILayoutPriority.required.rawValue) {
    self.init(width: .equal(size.width, priority), height: .equal(size.height, priority))
  }

  init(_ size: CGFloat) {
    self.init(.equal(size))
  }
}

struct ViewLayout: Equatable {
  let size: ViewSize?
  let padding: Padding?
  init(size: ViewSize? = nil, padding: Padding? = nil) {
    self.size = size
    self.padding = padding
  }
}

typealias ViewsLayout<ViewIDType: BaseViewID> = [ViewIDType: ViewLayout]

/// Padding specifies the distance between a view and its super view on its four sides. Padding uses
/// ``[LayoutPredicate]`` to specify values for each side, which allows the client to specify
/// multiple constraints for each side as well as to exclude sides by passing ``[]`` if no constraints
/// should be defined for a side which also overrides default values (for all sides,
/// or the horizontal or vertical axis respectively.
///
/// Examples:
///
/// ```swift
/// // [] means no constraints (because nil means fall back to default)
/// Padding([])
/// // All sides tied to parent with default priority:
/// Padding(0)
/// // All sides >=0@255:
/// Padding(.greaterThanOrEqual(0, 250))
/// // All sides 10@250 and >=0@999:
/// Padding([.equal(10, 250), greaterThanOrEqual(0, priority: .required]
/// // All sides 20, except top which is 10:
/// Padding(20, top: 10)
/// // Can't mix numbers and predicates:
/// Padding(.equal(20), top: .equal(10, 999)
/// // top: 20, trailing: 20, bottom: 5, leading: no constraint
/// Padding(20, vertical: 10, bottom: 5, leading: [])
/// ```
struct Padding: Equatable {
  let top: [LayoutPredicate]
  let trailing: [LayoutPredicate]
  let bottom: [LayoutPredicate]
  let leading: [LayoutPredicate]

  /// Defines the padding of a view.
  ///
  /// The first parameter (`allDefault`) specifies the default value for
  /// all sides while `vertical` and `horizontal` are defaults for the respective axis.
  ///
  /// The value for ``top`` would be `top ?? vertical ?? allDefault` while
  /// the value for ``leading`` would be `leading ?? horizontal ?? addDefault`.
  ///
  /// If you define a default and want some sides not to have any padding constraints, pass ``[]``:
  ///
  /// ```swift
  /// Padding(10, horizontal: 20, leading: [])
  /// ```
  ///
  /// This would result in ``top`` and ``bottom`` to have a padding of `10` while
  /// ``trailing`` would be `20` and ``leadig`` would have no padding constraint.
  ///
  /// A value of ``[]`` means no padding (-constraint) while ``0`` means a padding of zero.
  /// Multiple values result in multiple layout constraints being defined, for example:
  ///
  /// ```swift
  /// [.equal(5, 250), .lessThanOrEqual(10)]
  /// ```
  ///
  /// would result in two constraints ``"-(0@250,<=10)-"``
  init(
    _ allDefault: [LayoutPredicate]? = nil,
    vertical: [LayoutPredicate]? = nil,
    horizontal: [LayoutPredicate]? = nil,
    top: [LayoutPredicate]? = nil,
    trailing: [LayoutPredicate]? = nil,
    bottom: [LayoutPredicate]? = nil,
    leading: [LayoutPredicate]? = nil
  ) {
    self.top = top ?? vertical ?? allDefault ?? []
    self.trailing = trailing ?? horizontal ?? allDefault ?? []
    self.bottom = bottom ?? vertical ?? allDefault ?? []
    self.leading = leading ?? horizontal ?? allDefault ?? []
  }

  /// Same padding on all sides, equivalent to `init(.equal(padding, priority: .required))
  init(padding: CGFloat) {
    self.init([.equal(padding)])
  }
  /// This initializer uses single floats as parameters, which is easier to read but
  /// disables the feature to define mutiple constraints for a side
  init(
    _ allDefault: CGFloat? = nil,
    vertical: CGFloat? = nil,
    horizontal: CGFloat? = nil,
    top: CGFloat? = nil,
    trailing: CGFloat? = nil,
    bottom: CGFloat? = nil,
    leading: CGFloat? = nil
  ) {
    self.init(
      allDefault != nil ? [.equal(allDefault!)] : nil,
      vertical: vertical != nil ? [.equal(vertical!)] : nil,
      horizontal: horizontal != nil ? [.equal(horizontal!)] : nil,
      top: top != nil ? [.equal(top!)] : nil,
      trailing: trailing != nil ? [.equal(trailing!)] : nil,
      bottom: bottom != nil ? [.equal(bottom!)] : nil,
      leading: leading != nil ? [.equal(leading!)] : nil
    )
  }

  /// The number of constraints required to implement this padding specification
  var count: Int { top.count + trailing.count + bottom.count + leading.count }

  /// True if this padding does not specify any constraints (equivalent to `count == 0`)
  var isEmpty: Bool { top.isEmpty && trailing.isEmpty && bottom.isEmpty && leading.isEmpty }
  /// Visual format language string for padding constraints on the
  /// vertical axis (something like `"V:|-(top)-[view]-(bottom)-|"` or
  /// `"V:[view]-(bottom)-|"`)
  func vflVertical<ViewIDType: BaseViewID>(
    viewID: ViewIDType,
    relatedView: String = "|"
  ) -> String? {
    vflVertical(viewID: viewID.key)
  }
  /// Visual format language string for padding constraints on the
  /// vertical axis (something like `"V:|-(top)-[view]-(bottom)-|"` or
  /// `"V:[view]-(bottom)-|"`)
  func vflVertical(
    viewID: String,
    relatedView: String = "|"
  ) -> String? {
    var topVfl = top.vfl ?? ""
    var bottomVfl = bottom.vfl ?? ""
    let viewRef = relatedView == "|" ? "|" : "[\(relatedView)]"
    guard !topVfl.isEmpty || !bottomVfl.isEmpty else { return nil }

    if !topVfl.isEmpty {
      topVfl = "\(viewRef)\(topVfl)"
    }
    if !bottomVfl.isEmpty {
      bottomVfl = "\(bottomVfl)\(viewRef)"
    }

    return "V:\(topVfl)[\(viewID)]\(bottomVfl)"
  }

  /// Visual format language string for padding constraints on the
  /// horizontal axis (something like `"H:|-(leading)-[view]-(trailing)-|"` or
  /// `"H:[view]-(trailing)-|"`)
  func vflHorizontal<ViewIDType: BaseViewID>(
    viewID: ViewIDType,
    relatedView: String = "|"
  ) -> String? {
    vflHorizontal(viewID: viewID.key)
  }
  /// Visual format language string for padding constraints on the
  /// horizontal axis (something like `"H:|-(leading)-[view]-(trailing)"` or
  /// `"H:[view]-(trailing)-|"`)
  func vflHorizontal(
    viewID: String,
    relatedView: String = "|"
  ) -> String? {
    var leadingVfl = leading.vfl ?? ""
    var trailingVfl = trailing.vfl ?? ""
    let viewRef = relatedView == "|" ? "|" : "[\(relatedView)]"

    guard !leadingVfl.isEmpty || !trailingVfl.isEmpty else { return nil }

    if !leadingVfl.isEmpty {
      leadingVfl = "\(viewRef)\(leadingVfl)"
    }
    if !trailingVfl.isEmpty {
      trailingVfl = "\(trailingVfl)\(viewRef)"
    }
    return "H:\(leadingVfl)[\(viewID)]\(trailingVfl)"
  }
}
