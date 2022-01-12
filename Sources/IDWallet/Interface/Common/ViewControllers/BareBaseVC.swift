//
//  BareBaseVC.swift
//  IDWallet
//
//  Created by Michael Utech on 22.12.21.
//

import CocoaLumberjackSwift
import Foundation
import UIKit

/// Basic functionality for ``BaseViewController`` that does not depend on generic parameters.
///
/// This base view controller provides the following features:
/// - Tracks life cycle events and keeps a state in ``lifeCycleState`` and logs transitions at debug level
/// - Logs other noteworthy events at debug level
/// - Restricts interface orientation to portrait (project default)
/// - Sets the ``accessibilityIdentifier`` to the view controllers class name
class BareBaseViewController: UIViewController {

  /// Reflects the current life cycle state of the view controller.
  ///
  /// This is usefull if certain operations should only be executed if the view controller
  /// is or is not in certain stages.
  enum LifeCycleState: Int, Comparable {
    case uninitialized
    case initialized
    case didLoad
    case willAppear
    case willLayoutSubviews
    case didLayoutSubviews
    case didAppear
    case willDisappear
    case didDisappear

    static func < (lhs: LifeCycleState, rhs: LifeCycleState) -> Bool {
      return lhs.rawValue < rhs.rawValue
    }
  }

  // MARK: - Storage

  var privateLifeCycleState: LifeCycleState = .uninitialized {
    didSet {
      DDLogDebug("[life cycle event] \(logTag): \(lifeCycleState) (from \(oldValue))")
    }
  }

  var logTag: String = ""

  // MARK: - Access

  var lifeCycleState: LifeCycleState { privateLifeCycleState }

  // MARK: - Initialization

  init(style: ThemeContextDependent? = nil) {
    super.init(nibName: nil, bundle: nil)
    logTag = String(describing: type(of: self))
    privateLifeCycleState = .initialized
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    logTag = String(describing: type(of: self))
    privateLifeCycleState = .initialized
  }

  // MARK: - View Life Cycle

  override func viewDidLoad() {
    privateLifeCycleState = .didLoad

    if let view = view {
      view.accessibilityIdentifier = "\(String(describing: type(of: self))).view"
    }

    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    privateLifeCycleState = .willAppear
    super.viewWillAppear(animated)
  }

  override func viewWillLayoutSubviews() {
    privateLifeCycleState = .willLayoutSubviews
    super.viewWillLayoutSubviews()
  }

  override func viewDidLayoutSubviews() {
    privateLifeCycleState = .didLayoutSubviews
    super.viewDidLayoutSubviews()
  }

  override func viewDidAppear(_ animated: Bool) {
    privateLifeCycleState = .didAppear
    super.viewDidAppear(animated)
  }

  // MARK: - Default Behaviour Configuration

  /// idWallet is currently restricted to portrait orientation, individual view controllers might override this
  override var shouldAutorotate: Bool { false }

  /// idWallet is currently restricted to portrait orientation, individual view controllers might override this
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}
