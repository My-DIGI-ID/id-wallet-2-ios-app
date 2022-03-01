//
// Copyright 2022 Bundesrepublik Deutschland
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
// the License. You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
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
class BaseViewController: UIViewController {

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

    // MARK: - Default Behaviour Configuration

    var _preferredStatusBarStyle: UIStatusBarStyle = .darkContent

    override var preferredStatusBarStyle: UIStatusBarStyle {
        get { _preferredStatusBarStyle }
        set(value) {
            _preferredStatusBarStyle = value
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// idWallet is currently restricted to portrait orientation, individual view controllers might override this
    override var shouldAutorotate: Bool { false }

    /// idWallet is currently restricted to portrait orientation, individual view controllers might override this
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

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

    // MARK: - Initialization

    init() {
        super.init(nibName: nil, bundle: nil)
        logTag = String(describing: type(of: self))
        privateLifeCycleState = .initialized
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        logTag = String(describing: type(of: self))
        privateLifeCycleState = .initialized
    }
}
