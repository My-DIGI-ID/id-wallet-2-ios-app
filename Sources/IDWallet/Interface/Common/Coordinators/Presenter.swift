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

import Foundation
import UIKit
import CocoaLumberjackSwift

/// Animation related options for presenters
struct PresentationOptions {
    /// Default presentation options
    static var defaultOptions = PresentationOptions()

    static var notAnimated = PresentationOptions(animated: false)
    
    /// Determines whether a transition should be animated, defaults to `true`
    var animated: Bool = true

    /// The transition duration in ms, defaults to `0.2`
    var transitionDuration: CGFloat = 0.2

    /// The transition type, defaults to `.fade`
    var transitionType: CATransitionType = .fade
}

/// Animation related options for modal presenters
struct ModalPresentationOptions {
    /// Default modal presentation options (`.fullScreen`, `.crossDissolve`)
    static var defaultOptions = ModalPresentationOptions()

    /// Determines whether a modal presentation will be animated
    var animated: Bool = true

    /// The modal presentation style, defaults to `.fullScreen`
    var modalPresentationStyle: UIModalPresentationStyle = .fullScreen

    /// The modal transition style, defaults to `.crossDissolve`
    var modalTransitionStyle: UIModalTransitionStyle = .crossDissolve
}

/// Provides presentation and dismissal methods for modal presentations.
///
/// View controllers who need modal presentations should use a modal presenter
/// provided by the coordinator initializing the controller in favour to presenting them
/// manually.
protocol ModalPresenterProtocol: AnyObject {
    /// Presents a modal view controller. There can always only be one modal view controller
    /// presented at any time.
    /// - Parameter viewController: the controller to present
    /// - Parameter options: modal presentation options
    /// - Parameter completion: called when the presentation is completed (controller appeared)
    func presentModal(
        _ viewController: UIViewController,
        options: ModalPresentationOptions,
        completion: (() -> Void)?
    )

    /// Dismisses a modal view controller previously presented by `presentModal(_:options:)`.
    /// - Parameter completion: called when the dismissal of the currently presented controller completed.
    func dismissModal(completion: (() -> Void)?)
}

/// The presenter protocol is designed to provide a minimalistic and safe interface to ``Coordinator``s
/// enabeling them to present view controllers as activities.
protocol PresenterProtocol: ModalPresenterProtocol {
    /// Presents the first activity of a coordinator workflow. After calling this method, the coordinator
    /// has to use `present(_:replacing:options:)` in order to present successive activities.
    /// - Parameter viewController: the view controller to present
    /// - Parameter options:animation related presentation options
    /// - Parameter completion: called when the `viewController` appeared
    func present(
        _ viewController: UIViewController,
        options: PresentationOptions,
        completion: (() -> Void)?
    )

    /// Presents a view controller replacing the currently presented activity. Coordinators use this
    /// method when one activity completes and the next activity of the workflow starts.
    /// - Parameter viewController: the view controller to present
    /// - Parameter replacing: the previous activity's view controller
    /// - Parameter options: animation related presentation options
    func present(
        _ viewController: UIViewController,
        replacing: UIViewController,
        options: PresentationOptions,
        completion: (() -> Void)?
    )

    /// Dismisses the currently presented view controller. This should rarely if ever be needed. The use case
    /// would be to recreate the initial presentation state of a coordinator before its `start` method was first called.
    func dismiss(
        options: PresentationOptions,
        completion: (() -> Void)?
    )
}

extension PresenterProtocol {
    /// Convenience method calling either `present(_:options:)` if `viewController` is nil
    /// or present(_:replacing:options:)` otherwise
    func present(
        _ viewController: UIViewController,
        replacing: UIViewController? = nil,
        options: PresentationOptions = .defaultOptions
    ) {
        if let replacing = replacing {
            present(
                viewController, replacing: replacing,
                options: options)
        } else {
            present(
                viewController,
                options: options)
        }
    }

    /// Presents the first activity of a coordinator workflow. After calling this method, the coordinator
    /// has to use `present(_:replacing:options:)` in order to present successive activities.
    /// - Parameter viewController: the view controller to present
    /// - Parameter options:animation related presentation options
    func present(
        _ viewController: UIViewController,
        options: PresentationOptions
    ) {
        present(viewController, options: options, completion: nil)
    }

    /// Presents a view controller replacing the currently presented activity. Coordinators use this
    /// method when one activity completes and the next activity of the workflow starts.
    func present(
        _ viewController: UIViewController,
        replacing: UIViewController,
        options: PresentationOptions
    ) {
        present(viewController, replacing: replacing, options: options, completion: nil)
    }
}

extension ModalPresenterProtocol {
    /// Presents a modal view controller. There can always only be one modal view controller
    /// presented at any time.
    func presentModal(
        _ viewController: UIViewController,
        options: ModalPresentationOptions
    ) {
        presentModal(viewController, options: options, completion: nil)
    }
}

@objc
class RootPresenter: NSObject, PresenterProtocol, CAAnimationDelegate {
    private weak var _navigationController: UINavigationController?
    private var completionByAnimation = [CAAnimation: () -> Void]()

    private var navigationController: UINavigationController {
        guard let result = _navigationController else {
            ContractError.guardAssertionFailed().fatal()
        }
        return result
    }

    init(_ navigationController: UINavigationController) {
        _navigationController = navigationController
    }

    func present(
        _ viewController: UIViewController,
        options: PresentationOptions,
        completion: (() -> Void)?
    ) {
        let navigationController = navigationController

        animateTransition(options, completion: completion) {
            navigationController.pushViewController(viewController, animated: false)
        }
    }

    func present(
        _ viewController: UIViewController,
        replacing currentViewController: UIViewController,
        options: PresentationOptions,
        completion: (() -> Void)?
    ) {
        let navigationController = self.navigationController

        var viewControllers = navigationController.viewControllers
        let last = viewControllers.count - 1
        let top = viewControllers[last]

        guard top === currentViewController else {
            ContractError.guardAssertionFailed().fatal()
        }

        animateTransition(options, completion: completion) {
            viewControllers[last] = viewController
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }

    func dismiss(
        options: PresentationOptions,
        completion: (() -> Void)?
    ) {
        let navigationController = navigationController

        animateTransition(options, completion: completion) {
            navigationController.popViewController(animated: false)
        }
    }

    func presentModal(
        _ viewController: UIViewController,
        options: ModalPresentationOptions = .defaultOptions,
        completion: (() -> Void)?
    ) {
        let navigationController = self.navigationController
      
        if let top = navigationController.topViewController {
            viewController.modalPresentationStyle = options.modalPresentationStyle
            viewController.modalTransitionStyle = options.modalTransitionStyle
            top.present(viewController, animated: options.animated, completion: completion)
        }
    }

    func dismissModal(completion: (() -> Void)?) {
        let navigationController = self.navigationController

        if let presented = navigationController.presentedViewController {
            presented.dismiss(animated: true, completion: completion)
        }
    }

    private func animateTransition(_ options: PresentationOptions, completion: (() -> Void)?, animated action: () -> Void) {
        let transition = CATransition()
        transition.duration = options.transitionDuration
        transition.type = options.transitionType
        transition.delegate = self
        navigationController.view.layer.add(transition, forKey: nil)
        if let completion = completion {
            completionByAnimation[transition] = completion
        }
        action()
    }

    func animationDidStart(_ anim: CAAnimation) {
        if completionByAnimation.count > 1 {
            DDLogWarn(
                "Found more than one concurrent transition with completion blocks " +
                "(\(completionByAnimation.count), this may or may not be a problem, verify")
        }
        DDLogDebug("Animation did start: \(anim)")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let completion = completionByAnimation[anim] {
            DDLogDebug("Animation did end: \(anim), finished: \(flag), calling completion")
            completionByAnimation.removeValue(forKey: anim)
            completion()
        } else if completionByAnimation.count == 1 {
            if let original = completionByAnimation.keys.first, let completion = completionByAnimation[original] {

                DDLogWarn("Unknown animation did end: \(anim), finished: \(flag), calling completion for \(original)")
                completionByAnimation.removeAll()
                completion()
            }
        } else {
            DDLogDebug("Animation did end: \(anim), finished: \(flag), no completion registered")
        }
    }
}
