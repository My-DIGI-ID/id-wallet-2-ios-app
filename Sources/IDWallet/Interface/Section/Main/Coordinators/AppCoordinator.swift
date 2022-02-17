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
import SwiftUI
import CocoaLumberjackSwift

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
            case .authenticationError(let error):
                DDLogError(error)
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
                self?.startAuthentication()
            }
        )
        setupCoordinator.start()
    }

    private func startAuthentication(attempt: Int = 0, from previous: UIViewController? = nil) {
        if attempt > 5 {
            // TODO: message to user
            Task {
                try await appState.authenticator.reset()
                self.presenter.dismiss(options: .defaultOptions, completion: {
                    self.start()
                })
            }
        }

        let viewController = PinEntryViewController(
            style: .regular,
            viewModel: PinEntryViewModel.viewModelForPinEntry(
                resultHandler: { result, previous in
                    switch result {
                    case .pin(let pin, _):
                        let spinner = SpinnerViewController()
                        self.presenter.present(spinner, replacing: previous, options: .defaultOptions) {
                            Task {
                                let state: Authenticator.AuthenticationState = await self.appState.authenticator.authenticate(pin: pin)
                                switch state {
                                case .authenticated:
                                    self.startWallet(from: spinner)
                                default:
                                    self.startAuthentication(attempt: attempt + 1, from: spinner)
                                }
                            }
                        }
                    default:
                        self.startAuthentication(attempt: attempt, from: previous)
                    }
                },
                length: 6
            ))
        presenter.present(viewController, replacing: previous)
    }
    
    private func startWallet(from viewController: UIViewController? = nil) {
        presenter.present(WalletTabBarController(presenter: presenter), replacing: viewController)
    }
}
