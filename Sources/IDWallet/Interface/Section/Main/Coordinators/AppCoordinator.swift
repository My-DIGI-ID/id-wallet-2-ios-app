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
        let alert = UIAlertController(
            title: "Anmeldung",
            message:
                "Die PIN wurde gesetzt wird aber zum Testen wieder gelöscht da " +
            "die Wallet Funktionalität noch nicht implementiert ist.",
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(
                title: "OK", style: .default,
                handler: { [weak self] _ in
                    if let self = self {
                        self.appState.authenticator.reset()
                        self.start()
                    }
                }
            ))
        presenter.present(alert)
    }
    
    private func startWallet() {
        presenter.present(WalletTabBarController(presenter: presenter))
    }
}
