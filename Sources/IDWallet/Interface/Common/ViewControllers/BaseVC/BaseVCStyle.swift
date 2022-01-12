//
//  BaseViewControllerStyle.swift
//  IDWallet
//
//  Created by Michael Utech on 21.12.21.
//

import Foundation

// MARK: - Style config for BaseViewController
// MARK: -

/// Defines the required structure of a style for view controllers using the
/// ``BaseViewController``.
///
///
/// ``themeContext`` is used to determine an appropriate status bar
/// style and also to provide the tools in ``ViewFactory`` with the necessary
/// information.
protocol BaseViewControllerStyle: ThemeContextDependent {
  associatedtype LayoutType: BaseViewControllerLayout

  /// The default initializer is required to allow ``BaseViewController``
  /// to provide a status bar appearance even if the style is not yet set by
  /// the party configuring the view controller.
  init()

  /// This is used to expose parameters allowing a view controller
  /// to be customized witout requiring code changes. See ``BaseViewControllerLayout``
  var layout: LayoutType { get }

  /// This is used to provide a default status bar appearance as well as
  /// to support tools provided ``ViewFactory``
  var themeContext: ThemeContext { get }
}
