//
//  LayoutFactory.swift
//  IDWallet
//
//  Created by Michael Utech on 23.12.21.
//

import Foundation
import UIKit
import CocoaLumberjackSwift

protocol LayoutFactory {
  var hasControlledConstraints: Bool { get }
  var viewsForLayout: [String: UIView] { get }

  @discardableResult
  func addControlledConstraints(
    _ constraints: [NSLayoutConstraint], identifier: String, activate: Bool
  ) -> [NSLayoutConstraint]

}

extension LayoutFactory {

  @discardableResult
  func addConstraint(
    _ constraint: NSLayoutConstraint,
    identifier: String,
    activate: Bool = true,
    then: ((NSLayoutConstraint) -> Void)? = nil
  ) -> NSLayoutConstraint {
    addControlledConstraints([constraint], identifier: identifier, activate: true)
    if let then = then {
      then(constraint)
    }
    return constraint
  }

  func addConstraintsFillingSuperviewHorizontally(
    view: UIView,
    identifier: String? = nil,
    activate: Bool = true
  ) {
    guard let container = view.superview else {
      ContractError.guardAssertionFailed(
        "view [\(view)] has no super view, constraints embedding the view its superview cannot be created"
      ).fatal()
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    var id: String! = identifier
    if id == nil {
      guard let viewId = view.accessibilityIdentifier else {
        ContractError.guardAssertionFailed(
          "Constraint identifier might only be omitted if view [\(view)] defines an accessibilityIdentifier"
        ).fatal()
      }
      id = "[\(viewId)]-filling-superview-horizontally"
      if let parentId = container.accessibilityIdentifier {
        id = "\(id!)-[\(parentId)]"
      }
    }
    addControlledConstraints(
      [
        view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
        view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
      ],
      identifier: id,
      activate: activate)
  }

  func addConstraintsFillingSuperviewVertically(
    view: UIView,
    identifier: String? = nil,
    activate: Bool = true
  ) -> [NSLayoutConstraint] {
    guard let container = view.superview else {
      ContractError.guardAssertionFailed(
        "view [\(view)] has no super view, constraints embedding the view its superview cannot be created"
      ).fatal()
    }
    view.translatesAutoresizingMaskIntoConstraints = false
    var id: String! = identifier
    if id == nil {
      guard let viewId = view.accessibilityIdentifier else {
        ContractError.guardAssertionFailed(
          "Constraint identifier might only be omitted if view [\(view)] defines an accessibilityIdentifier"
        ).fatal()
      }
      id = "[\(viewId)]-filling-superview-vertically"
      if let parentId = container.accessibilityIdentifier {
        id = "\(id!)-[\(parentId)]"
      }
    }
    let constraints = [
      view.topAnchor.constraint(equalTo: container.topAnchor),
      view.bottomAnchor.constraint(equalTo: container.bottomAnchor)
    ]
    addControlledConstraints(
      constraints,
      identifier: id,
      activate: activate)
    return constraints
  }

  @discardableResult
  func addConstraintsFillingSuperview(
    view: UIView,
    identifier: String? = nil,
    activate: Bool = true
  ) -> [NSLayoutConstraint] {
    guard let container = view.superview else {
      ContractError.guardAssertionFailed(
        "view [\(view)] has no super view, constraints embedding the view its superview cannot be created"
      ).fatal()
    }

    view.translatesAutoresizingMaskIntoConstraints = false

    var id: String! = identifier
    if id == nil {
      guard let viewId = view.accessibilityIdentifier else {
        ContractError.guardAssertionFailed(
          "Constraint identifier might only be omitted if view [\(view)] defines an accessibilityIdentifier"
        ).fatal()
      }
      id = "[\(viewId)]-filling-superview"
      if let parentId = container.accessibilityIdentifier {
        id = "\(id!)-[\(parentId)]"
      }
    }
    let constraints = [
      view.topAnchor.constraint(equalTo: container.topAnchor),
      view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
      view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
    ]
    addControlledConstraints(
      constraints,
      identifier: id,
      activate: activate)
    return constraints
  }

  @discardableResult
  func addConstraintsForPadding(
    _ padding: Padding,
    view: UIView,
    in container: UIView? = nil,
    identifier: String? = nil,
    activate: Bool = true
  ) -> [NSLayoutConstraint] {
    guard let id = view.accessibilityIdentifier else {
      ContractError.guardAssertionFailed(
        "Constraint identifier might only be omitted if view [\(view)] defines an accessibilityIdentifier"
      ).fatal()
    }

    if let container = container, container != view.superview {
      DDLogWarn("container for padding [\(container)] is not [\(view)]'s superview")
    }

    var constraints = [NSLayoutConstraint]()
    let views = [id: view]
    if let vertical = padding.vflVertical(viewID: id) {
      constraints.append(
        contentsOf: NSLayoutConstraint.constraints(
          withVisualFormat: vertical,
          options: .init(), metrics: nil, views: views))
    }
    if let horizontal = padding.vflHorizontal(viewID: id) {
      constraints.append(
        contentsOf: NSLayoutConstraint.constraints(
          withVisualFormat: horizontal,
          options: .init(), metrics: nil, views: views))
    }
    addControlledConstraints(constraints, identifier: identifier ?? "\(id)-padding", activate: activate)
    return constraints
  }

  @discardableResult
  func addConstraintsForViewLayout(
    _ layout: ViewLayout,
    view: UIView,
    identifier: String? = nil
  ) -> [NSLayoutConstraint] {
    guard let id = identifier ?? view.accessibilityIdentifier else {
      ContractError.guardAssertionFailed(
        "Constraint identifier might only be omitted if view [\(view)] defines an accessibilityIdentifier"
      ).fatal()
    }
    var constraints = [NSLayoutConstraint]()

    if let padding = layout.padding {
      constraints.append(
        contentsOf: addConstraintsForPadding(
          padding,
          view: view,
          identifier: "\(id)-layout-padding"))
    }

    if let size = layout.size {
      constraints.append(
        contentsOf: addConstraintsForViewSize(
          size,
          view: view,
          identifier: "\(id)-layout-size"))
    }

    return constraints
  }

  @discardableResult
  func addConstraintsForViewSize(
    _ size: ViewSize,
    view: UIView,
    identifier: String? = nil,
    activate: Bool = true
  ) -> [NSLayoutConstraint] {
    guard let id = identifier ?? view.accessibilityIdentifier else {
      ContractError.guardAssertionFailed(
        "Constraint identifier might only be omitted if view [\(view)] defines an accessibilityIdentifier"
      ).fatal()
    }
    var constraints = [NSLayoutConstraint]()

    for width in size.width {
      let constraint = NSLayoutConstraint(
        item: view,
        attribute: .width,
        relatedBy: width.relation,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: width.constant)
      if let priority = width.priority {
        constraint.priority = priority
      }
      constraint.identifier = "\(identifier ?? "\(id)-size")-width"
      constraints.append(constraint)
    }

    for height in size.height {
      let constraint = NSLayoutConstraint(
        item: view,
        attribute: .height,
        relatedBy: height.relation,
        toItem: nil,
        attribute: .notAnAttribute,
        multiplier: 1,
        constant: height.constant)
      if let priority = height.priority {
        constraint.priority = priority
      }
      constraint.identifier = "\(identifier ?? "\(id)-size")-height"
      constraints.append(constraint)
    }

    return addControlledConstraints(constraints, identifier: identifier ?? "\(id)-size", activate: true)
  }

  @discardableResult
  func addConstraints(
    withVisualFormat format: String,
    options: NSLayoutConstraint.FormatOptions = .init(),
    metrics: [String: Any]? = nil,
    views: [String: UIView],
    identifier: String,
    activate: Bool = true
  ) -> [NSLayoutConstraint] {
    return addControlledConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: format, options: options, metrics: metrics, views: views),
      identifier: identifier,
      activate: activate)
  }

  func alignTopAndBottom(
    _ first: UIView, _ others: UIView...,
    identifier: String,
    activate: Bool = true
  ) {
    alignTopAndBottom(first, views: others, identifier: identifier, activate: activate)
  }

  func alignTopAndBottom(
    _ first: UIView, views: [UIView],
    identifier: String,
    activate: Bool = true
  ) {
    guard views.count > 1 else { return }

    var constraints = [NSLayoutConstraint]()
    for view in views {
      constraints.append(first.topAnchor.constraint(equalTo: view.topAnchor))
      constraints.append(first.bottomAnchor.constraint(equalTo: view.bottomAnchor))
    }
    addControlledConstraints(constraints, identifier: identifier, activate: activate)
  }
}
