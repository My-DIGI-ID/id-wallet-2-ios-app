//
//  Presenter.swift
//  IDWallet
//
//  Created by Michael Utech on 16.12.21.
//

import Foundation
import UIKit
import CryptoKit

struct PresentationOptions {
    static var defaultOptions = PresentationOptions()
    var animated: Bool = true
    var transitionDuration: CGFloat = 0.2
    var transitionType: CATransitionType = .fade
}

struct ModalPresentationOptions {
    static var defaultOptions = ModalPresentationOptions()
    var animated: Bool = true
    var modalPresentationStyle: UIModalPresentationStyle = .fullScreen
    var modalTransitionStyle: UIModalTransitionStyle = .crossDissolve
}

protocol ModalPresenterProtocol: AnyObject {

    /// Presents a modal view controller. There can always only be one modal view controller
    /// presented at any time.
    func presentModal(
        _ viewController: UIViewController,
        options: ModalPresentationOptions,
        completion: (() -> Void)?
    )

    /// Dismisses a modal view controller previously presented by `presentModal(_:options:)`.
    func dismissModal(completion: (() -> Void)?)
}

/// The presenter protocol is designed to provide a minimalistic and safe interface to ``Coordinator``s
/// enabeling them to present view controllers as activities.
protocol PresenterProtocol: ModalPresenterProtocol {
    /// Presents the first activity of a coordinator workflow. After calling this method, the coordinator
    /// has to use `present(_:replacing:options:)` in order to present successive activities.
    func present(
        _ viewController: UIViewController,
        options: PresentationOptions,
        completion: (() -> Void)?
    )

    /// Presents a view controller replacing the currently presented activity. Coordinators use this
    /// method when one activity completes and the next activity of the workflow starts.
    func present(
        _ viewController: UIViewController,
        replacing: UIViewController,
        options: PresentationOptions,
        completion: (() -> Void)?
    )

    func dismiss(
        options: PresentationOptions,
        completion: (() -> Void)?
    )
}

extension PresenterProtocol {
    func present(
        _ viewController: UIViewController,
        replacing: UIViewController? = nil,
        options: PresentationOptions = .defaultOptions
    ) {
        if let replacing = replacing {
            present(viewController, replacing: replacing,
                    options: options)
        } else {
            present(viewController,
                    options: options)
        }
    }

    /// Presents the first activity of a coordinator workflow. After calling this method, the coordinator
    /// has to use `present(_:replacing:options:)` in order to present successive activities.
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
    private var completionByAnimation = Dictionary<CAAnimation, () -> Void>()

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
            print("Found more than one concurrent transition with completion blocks (\(completionByAnimation.count), this may or may not be a problem, verify")
        }
        print("Animation did start: \(anim)")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
	// TODO: Remove debug output
        if let completion = completionByAnimation[anim] {
            print("Animation did end: \(anim), finished: \(flag), calling completion")
            completionByAnimation.removeValue(forKey: anim)
            completion()
        } else {
            print("Animation did end: \(anim), finished: \(flag), no completion registered")
        }
    }
}
