//
//  Coordinator.swift
//  IDWallet
//
//  Created by Michael Utech on 15.12.21.
//

import Foundation
import UIKit

/// Minimalistic implementation of the coordinator pattern.
///
/// Coordinators are pretty much free to do whatever they want, however,
/// here is an example of how this pattern is supposed to be implemented:
///
/// ```swift
/// @MainActor
/// class SomeCoordinator: Coordinator {
///   // Used by the coordinator to present view controllers
///   private let presenter: PresenterProtocol
///
///   // Provides the coordinator with data and actions
///   private let model: SomeModel
///
///   // Used to notify the calling coordinator or actor when
///   // the coordinators workflow is finished
///   private let completion: () -> Void
///
///   init(
///     presenter: PresenterProtocol,
///     model: SomeModel,
///     completion: @escaping () -> Void
///   ) {
///     self.presenter = presenter
///     self.model = model
///     self.completion = completion
///   }
///
///   func start() {
///     // See ``SetupCoordinator`` for an example of how and what to do.
///     startSomething()
///   }
/// }
/// ```
///
/// In short, the coordinator gets a presenter handling the chore of showing and dismissing
/// view controllers, either as full screen modals, stacked or paged which is up to the
/// party providing the presenter.
///
/// The model is the interface to the world and should be minimalistic, not providing
/// any functionality not required by a concrete coordinator. It should also not be a
/// view model assuming presentational roles.
///
/// The coordinator handles view controllers (and sub-coordinators) like atomic
/// asynchronuous function calls, mediating between its caller, the model and
/// callees.
///
/// A coordinator typically defines a private method for each workflow step in which
/// one view controller or sub coordinator is instantiated. It provides a view model
/// for a view controller or a sub-model for a sub coordinator.
///
/// The called view controller or sub coordinator returns the optional result of its
/// presentation and the un-dismissed view controller if any. The coordinator
/// function will then decide what to do with the result, e.g. which view controller
/// to present next, how to dismiss the currently open controller or whether and
/// how to finish its operation.
///
/// The goal of the whole concept is to decouple UI elements and replace the fuzzy
/// interface between iOS views, controllers, models, view models, navigation, etc. with
/// a simple concept (the function call with defined parameters and results).
///
/// A centralized state management is not required by this concept, but it can
/// be implemented by defining the model actions and queries to use the
/// centralized store. The coordinator will always only be able to reduce the surface
/// of a model by extracting parts of it and providing its sub coordinators or
/// view controllers with subsets of this model.
///
/// See ``MainCoordinator`` and ``SetupCoordinator``
@MainActor
protocol Coordinator: AnyObject {
  func start()
}
