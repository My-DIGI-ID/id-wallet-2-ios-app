//
//  SetupCoordinator.swift
//  IDWallet
//
//  Created by Michael Utech on 16.12.21.
//

import Foundation
import UIKit

@MainActor
class SetupCoordinator: Coordinator {
  private let presenter: PresenterProtocol
  private let model: Authenticator
  private let completion: () -> Void

  init(presenter: PresenterProtocol, model: Authenticator, completion: @escaping () -> Void) {
    self.presenter = presenter
    self.model = model
    self.completion = completion
  }

  func start() {
    startOnboarding()
  }
}

// MARK: - Workflow Implementations

extension SetupCoordinator {

  private func startOnboarding(from previous: UIViewController? = nil) {
    let viewModel = OnboardingViewController.ViewModel(
      commit: { viewController in
        self.startPinEntryInstructions(from: viewController)
      },
      showInfo: { viewController in
        self.startOnboardingShowAdditionalInformation(from: viewController)
      }
    )
    presenter.present(
      OnboardingViewController(style: .regular, viewModel: viewModel), replacing: previous)
  }

  private func startOnboardingShowAdditionalInformation(
    from viewController: OnboardingViewController
  ) {
    let alert = UIAlertController(
      title: "TODO: Mehr erfahren",
      message: "Lorem ipsum?",
      preferredStyle: .alert)
    alert.addAction(
      UIAlertAction(
        title: "OK", style: .default,
        handler: { _ in
          // nothing to do
        }
      ))
    viewController.present(alert, animated: true)
  }

  private func startPinEntryInstructions(from previous: UIViewController) {
    let viewModel = PinEntryIntroViewController.ViewModel(
      commit: { viewController in
        self.startInitialPinEntry(from: viewController)
      },
      cancel: { viewController in
        self.startOnboarding(from: viewController)
      }
    )
    let style = PinEntryIntroViewController.Style()
    presenter.present(
      PinEntryIntroViewController(style: style, viewModel: viewModel), replacing: previous)
  }

  private func startInitialPinEntry(from previous: UIViewController) {
    let viewController = PinEntryViewController(
      style: .regular,
      viewModel: PinEntryViewModel.viewModelForInitialPinEntry(
        resultHandler: { result, viewController in
          switch result {
          case .pin(let pin, _):
            self.startConfirmationPinEntry(from: viewController, pin: pin)
          case .cancelled:
            self.startOnboarding(from: viewController)
          }
        },
        length: 6
      ))
    presenter.present(viewController, replacing: previous)
  }

  private func startConfirmationPinEntry(
    from previous: PinEntryViewController, pin previousPin: String
  ) {
    let viewController = PinEntryViewController(
      style: .regular,
      viewModel: previous.viewModel.viewModelForConfirmation(
        resultHandler: { result, viewController in
          switch result {
          case .pin(let pin, _):
            if pin == previousPin {
              self.startPinEntrySuccess(from: viewController, pin: pin)
            } else {
              self.startPinEntryFailure(from: viewController)
            }
          case .cancelled:
            self.startOnboarding(from: viewController)
          }
        }))
    presenter.present(viewController, replacing: previous)
  }

  private func startPinEntrySuccess(from previous: PinEntryViewController, pin: String) {
    let viewModel = PinEntrySuccessViewController.ViewModel(
      commit: { viewController in
        Task {
          await self.model.definePIN(pin: pin)
          self.finish(from: viewController)
        }
      },
      cancel: { viewController in
        self.startOnboarding(from: viewController)
      }
    )
    let style = PinEntrySuccessViewController.Style()
    presenter.present(
      PinEntrySuccessViewController(style: style, viewModel: viewModel), replacing: previous)
  }

  private func startPinEntryFailure(from previous: PinEntryViewController) {
    let alert = UIAlertController(
      title: "Die Zugangscodes stimmen nicht überein",
      message: "Bitte bestätige deinen Zugangscode noch einmal",
      preferredStyle: .alert)
    alert.addAction(
      UIAlertAction(
        title: "Nochmal versuchen", style: .default,
        handler: { _ in
          self.startInitialPinEntry(from: previous)
        }
      ))
    previous.present(alert, animated: true)
  }

  private func finish(from viewController: UIViewController?) {
    if let viewController = viewController {
      viewController.dismiss(animated: true) {
        self.completion()
      }
    } else {
      completion()
    }
  }
}
