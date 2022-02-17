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

    /// Displays the first onboarding screen providing general information about the App
    ///
    /// Can be called as initial activity or from any other activity (f.e. cancelled operations)
    private func startOnboarding(from previous: UIViewController? = nil) {
        presenter.present(
            OnboardingViewController(
                viewModel: .init(modalPresenter: self.presenter)
            ) { viewController in
                self.startPinEntryInstructions(from: viewController)
            },
            replacing: previous
        )
    }

    /// Displays instructions for defining a PIN.
    ///
    /// Called from onboarding and after a failed confirmation PIN entry
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

    /// Displays a form letting the user enter the PIN
    ///
    /// Called from PIN Entry Instructions or after a failed PIN entry
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

    /// Display a form letting the user enter the confirmation PIN
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
                            Task {
                                self.presenter.presentModal(SpinnerViewController(), options: .init(animated: true, modalPresentationStyle: .fullScreen, modalTransitionStyle: .crossDissolve))
                                await self.model.definePIN(pin: pin)
                                self.presenter.dismissModal(completion: nil)
                                self.startPinEntrySuccess(from: viewController, pin: pin)
                            }
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
                    self.finish(from: viewController)
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
            message: "Bitte bestätige Deinen Zugangscode noch einmal",
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
