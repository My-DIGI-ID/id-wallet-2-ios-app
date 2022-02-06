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
    var cancelable: AnyCancellable?

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

    private func showHelp(viewModel: WebViewViewModelProtocol) {
        let help = HelpViewCoordinator(presenter: presenter, model: viewModel)
        help.start()
    }

    private func showMessage(viewModel: MessageViewModel) {
        let alert = MessageCoordinator(presenter: presenter, model: viewModel)
        alert.start()

        /* Example for a success message with close
         showMessage(viewModel: MessageViewModel(messageType: .success,
                                                 header: "Daten erfolgreich übermittelt",
                                                 buttons: [("Fertig", UIAction(handler: { _ in self.presenter.dismiss(completion: nil)}))]))
         */
    }

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

    private func startScanner() {

       scannerCoordinator = ScannerCoordinator.init(presenter: presenter) { result in
            switch result {
            case .success(let scanned):
                print(scanned)
            case .failure(let error):
                print(error)
            }
        }
        scannerCoordinator?.start()
    }

    private func startWallet() {

        scannerCoordinator = ScannerCoordinator.init(presenter: presenter) { result in
             switch result {
             case .success(let scanned):
                 print(scanned)
             case .failure(let error):
                 print(error)
             }
         }

        presenter.present(WalletTabBarController(scannerCoordinator: scannerCoordinator))
    }

    private func startConfirmation() {
        ConnectionConfirmationCoordinator(presenter: presenter).start()
    }
}
