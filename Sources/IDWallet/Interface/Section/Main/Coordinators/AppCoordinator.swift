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
import Combine

// MARK: - Coordinator Interface

@MainActor
class AppCoordinator: Coordinator {
    private let appState: AppState
    private let presenter: PresenterProtocol
    
    // TODO: Remove?
    var cancelable: AnyCancellable?
    
    // TODO: Move to where startScanner goes (Wallet Tabs)
    private var scannerCoordinator: ScannerCoordinator?
    
    init(presenter: PresenterProtocol, appState: AppState) {
        self.presenter = presenter
        self.appState = appState
    }
    
    func start() {
        Task {
            switch await appState.authenticator.authenticationState() {
            case .uninitialized:
                startSetup()
            case .unauthenticated, .authenticationFailed, .authenticationExpired:
                startAuthentication()
            case .authenticated:
                startWallet()
            }
        }
    }
}

// MARK: - Coordinator Workflow Implementation

extension AppCoordinator {
    
    private func startSetup() {
        let setupCoordinator = SetupCoordinator(
            presenter: presenter,
            model: appState.authenticator,
            completion: { [weak self] in
                self?.start()
            }
        )
        setupCoordinator.start()
    }

    private func startAuthentication() {

        let viewController = PinEntryViewController(
            style: .regular,
            viewModel: PinEntryViewModel.viewModelForInitialPinEntry(
                resultHandler: { result, viewController in
                    self.presenter.presentModal(SpinnerViewController(), options: .init(animated: true, modalPresentationStyle: .fullScreen, modalTransitionStyle: .crossDissolve))
                    switch result {
                    case .pin(let pin, _):
                        Task {
                            let state: Authenticator.AuthenticationState = await self.appState.authenticator.authenticate(pin: pin)
                            switch state {
                            case .authenticated:
                                self.presenter.dismissModal {
                                    self.startWallet(from: viewController)
                                }
                            default:
                                self.presenter.dismissModal(completion: nil)
                            }
                        }
                    case .cancelled:
                        self.presenter.dismissModal(completion: nil)
                    }
                },
                length: 6
            ))
        presenter.present(viewController)
    }
    
    private func startWallet(from viewController: UIViewController? = nil) {
        presenter.present(WalletTabBarController(presenter: presenter), replacing: viewController)
    }
}
