//
//  BaseVCLayout.swift
//  IDWallet
//
//  Created by Michael Utech on 21.12.21.
//

import Foundation

// MARK: - Layout config for BaseViewController
// MARK: -

/// Defines layout parameters used by view controllers inheriting from
/// ``BaseViewController``
///
/// This serves two purposes. One is to collect all layout parameters and
/// constants used by a view controller in one place and the second is
/// to provide an interface to the client allowing it to customize the
/// view controllers appearance.
///
/// Please note that some metrics in the following example use ``LayoutPredicate``s
/// which is a convenient way to allow the specification of priorities or multiple
/// constraints with potentially different relations and/or priorities.
///
/// Example for a concrete implementation:
/// ```swift
/// extension SomeViewController {
/// struct Layout: BaseViewControllerLayout {
///     static let regular = Layout(
///         // The implementation should document here which customizations
///         // are safe. (Tradeoff between robustness and flexibility)
///         views: [
///             // defines the padding of the toplevel layout container
///             .containerView: .init(padding: .init(0, top: 20, bottom 10)),
///             // defines a fixed size for an image view
///             .imageView:     .init(size:    .init(width: 10, height: 20))
///         ],
///         // this could be used to configure a UIViewStack spacing (thus only
///         // support CGFloat and not [LayoutPredicate])
///         verticalSpacing: 20,
///         // this could be used to set the horizontal padding of some
///         // views, as shown here using multiple constraints.
///         horizontalPadding: [.equal(10, 750), .greaterThanOrEqual(0)]
///     )
///     static let compressed = Layout(
///         views: [
///             .containerView: .init(padding: .init(0, top: 15, bottom 7)),
///             .imageView:     .init(size:    .init(width: 5, height: 10))
///         ],
///         verticalSpacing: 20,
///         // Even if the parameter type is [LayoutPredicate], you can use
///         // a single constraint without an array literal:
///         horizontalPadding: .equal(5)
///     )
///
///     let views: ViewsLayout<ViewID>
///     let verticalSpacing: CGFloat
///     // Use this if your layout is able and willing to create multiple
///     // constraints for this parameter
///     let horizontalPadding: [LayoutPredicate]
///     // Use this if the parameter should result in a single constraint
///     let singlePredicateParameter: LayoutPredicate?
/// ```
///
/// Here, `compressed` could be used on devices with limited screen estate as an alternative to
/// the ``regular`` settings.
///
/// Clients of this view controller could also customize the parameters in order to tweak the appearance of the
/// view controller.
///
/// The settings in ``views`` are not applied automatically. View controllers using this facility typically call
/// ``BaseViewController.addConstraintsForViewsLayout()`` in
/// their implementation of ``createOrUpdateConstraints()`` in oder to apply these settings.
protocol BaseViewControllerLayout: Equatable {
  /// The ViewID type that identifies all views created or adopted by the concrete view controller
  /// class. This is used by all parties accessing specific views, such as
  /// ``BaseViewController.createOrUpdateViews()``,
  /// ``BaseViewController.createOrUpdateConstraints()`` as well
  /// as UI test code in need of identifying or accessing specific well known views.
  associatedtype ViewIDType: BaseViewID

  /// This defines the view controllers default layout.
  static var regular: Self { get }

  /// This provides the possibility to specify the size and padding of each well known view.
  ///
  /// The implementation can choose to either indiscriminately implement constraints for these
  /// settings (by calling ``BaseViewController.addConstraintsForViewsLayout(:)``)
  /// or support only specific settings (which it should document in its implementation of this
  /// protocol).
  var views: ViewsLayout<ViewIDType> { get }
}
