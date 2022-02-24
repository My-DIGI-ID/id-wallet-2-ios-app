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
        presenter.present(
            PinEntryIntroViewController { viewController, result in
                switch result {
                case .committed:
                    self.startInitialPinEntry(from: viewController)
                case .cancelled:
                    self.startOnboarding(from: viewController)
                }
            },
            replacing: previous)
    }

    /// Displays a form letting the user enter the PIN
    ///
    /// Called from PIN Entry Instructions or after a failed PIN entry
    private func startInitialPinEntry(from previous: UIViewController) {
        let viewController = PinEntryViewController(
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
            viewModel: previous.viewModel.viewModelForConfirmation(
                resultHandler: { result, viewController in
                    switch result {
                    case .pin(let pin, _):
                        if pin == previousPin {
                            Task {
                                self.presenter.presentModal(SpinnerViewController(), options: .defaultOptions)
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
    
    private func startPinEntrySuccess(from previous: PinEntryViewController?, pin: String) {
        var viewController: UIViewController?
        let viewModel = MessageViewModel(
            messageType: .success,
            header: "ID Wallet einrichten",
            text: "Du hast Deinen Zugangscode erfolgreich festgelegt.\n\n" +
                "Du kannst jetzt weiter zur Wallet und dort Deine ersten Nachweise erstellen",
            buttons: [ButtonConfig(title: "Weiter zur Wallet", image: nil, action: UIAction { _ in
                self.finish(from: viewController!)
            })
            ])

        viewController = WalletMessageViewController(viewModel: viewModel)
        presenter.present(
            viewController!,
            replacing: previous)
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
