//
//  BaseViewID.swift
//  IDWallet
//
//  Created by Michael Utech on 21.12.21.
//

import Foundation

/// Identifies controlled views (views created or adopted by the view controller) or
/// otherwise well known views participating in the UI.
///
/// View controllers extending ``BaseViewController`` are expected to define
/// an enum `ViewID` like so:
///
/// ```swift
/// extension SomeViewController {
///     enum ViewID: String, BaseViewID {
///         case containerView
///         case someContentView
///
///         var key: { String { return rawValue } }
///     }
/// }
/// ```
///
/// Each view that is controlled by the view controller should have an enumeration value.
/// This will be used to set up the ``UIView.accessibilityIdentifier`` as well
/// as to identifiy the view in various other contexts.
///
/// If the view controller uses the factory and support methods provided by
/// ``BaseViewController``, setting the
/// accessibility identifier is automatically done by `makeOrUpdate` methods.
///
/// Factory methods creating or registering constraints also make use of these IDs
/// to set constraint identifiers automatically making it easier to see to which views a constraint is related
/// to.
///
/// Lastly, accessibility identifier can be used in UI testing and these enum values
/// can be used to query for these identifiers as enums instead of raw string constants.
///
/// An extension to this protocol provides ``description`` implementing
/// ``CustomStringConvertible``.
protocol BaseViewID: CustomStringConvertible, Hashable {

  /// This is used to set the ``accessibilityIdentifier`` of the associated
  /// view, to obtain a reference to the view from the implementing view controller
  /// (``BaseViewController.controlledView(id)``) or to query
  /// for a matching view in UI tests.
  var key: String { get }
}

// Default implementation of CustomStringConvertible.
extension BaseViewID {
  var description: String { key }
}
