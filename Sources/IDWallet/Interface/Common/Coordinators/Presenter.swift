//
//  Presenter.swift
//  IDWallet
//
//  Created by Michael Utech on 16.12.21.
//

import Foundation
import UIKit

/// The presenter protocol is designed to provide a minimalistic and safe interface to ``Coordinator``s
/// enabeling them to present view controllers.
protocol PresenterProtocol: AnyObject {
  func present(
    _ viewController: UIViewController,
    replacing: UIViewController,
    modalPresentationStyle: UIModalPresentationStyle,
    modalTransitionStyle: UIModalTransitionStyle,
    animated: Bool,
    completion: (() -> Void)?
  )

  func present(
    _ viewController: UIViewController,
    modalPresentationStyle: UIModalPresentationStyle,
    modalTransitionStyle: UIModalTransitionStyle,
    animated: Bool,
    completion: (() -> Void)?
  )

    func dismiss(completion: (() -> Void)?)
}

extension PresenterProtocol {

  func present(
    _ viewController: UIViewController,
    replacing: UIViewController? = nil,
    animated: Bool = true,
    modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
    modalTransitionStyle: UIModalTransitionStyle = .crossDissolve,
    completion: (() -> Void)? = nil
  ) {
    if let replacing = replacing {
      present(viewController, replacing: replacing,
              modalPresentationStyle: modalPresentationStyle,
              modalTransitionStyle: modalTransitionStyle,
              animated: true,
              completion: nil)
    } else {
      present(viewController,
              modalPresentationStyle: modalPresentationStyle,
              modalTransitionStyle: modalTransitionStyle,
              animated: true,
              completion: nil)
    }
  }
}

class Presenter: PresenterProtocol {
  private weak var _navigationController: UINavigationController?

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
    replacing currentViewController: UIViewController,
    modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
    modalTransitionStyle: UIModalTransitionStyle = .crossDissolve,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) {
    let navigationController = self.navigationController

    guard let top = navigationController.topViewController,
      let presented = top.presentedViewController,
      currentViewController === presented
    else {
      ContractError.guardAssertionFailed().fatal()
    }

    currentViewController.modalTransitionStyle = modalTransitionStyle
    viewController.modalPresentationStyle = modalPresentationStyle
    viewController.modalTransitionStyle = modalTransitionStyle
    currentViewController.dismiss(animated: false) {
      top.present(viewController, animated: true, completion: completion)
    }
  }

  func present(
    _ viewController: UIViewController,
    modalPresentationStyle: UIModalPresentationStyle = .fullScreen,
    modalTransitionStyle: UIModalTransitionStyle = .crossDissolve,
    animated: Bool = true,
    completion: (() -> Void)? = nil
  ) {
    let navigationController = self.navigationController
      
    if let top = navigationController.topViewController {
      guard top.presentedViewController == nil else {
        ContractError.guardAssertionFailed(
          "Cannot present more than one modal view controller, use present(_:replacing:) instead"
        ).fatal()
      }

      viewController.modalPresentationStyle = modalPresentationStyle
      viewController.modalTransitionStyle = modalTransitionStyle
      top.present(viewController, animated: animated) {
        completion?()
      }
    }
  }

    func dismiss(completion: (() -> Void)? = nil) {
        let nav = self.navigationController
        nav.topViewController?.dismiss(animated: true, completion: completion)
    }
}
