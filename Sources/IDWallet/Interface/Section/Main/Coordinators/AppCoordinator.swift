//
//  AppCoordinator.swift
//  IDWallet
//
//  Created by Michael Utech on 16.12.21.
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
                startWallet()
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
