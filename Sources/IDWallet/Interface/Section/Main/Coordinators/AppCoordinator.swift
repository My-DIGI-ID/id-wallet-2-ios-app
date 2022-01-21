//
//  AppCoordinator.swift
//  IDWallet
//
//  Created by Michael Utech on 16.12.21.
//

import Foundation
import UIKit
import SwiftUI

// MARK: - Coordinator Interface

@MainActor
class AppCoordinator: Coordinator {
  private let appState: AppState
  private let presenter: PresenterProtocol
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
    
    private func showError(viewModel: ErrorAlertViewModel) {
        let alert = ErrorAlertCoordinator(presenter: presenter, model: viewModel)
        alert.start()
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

  private func startWallet() {
      
      let primaryAction = UIAction(handler: { [weak self] _ in
          self?.presenter.dismiss(completion: {
              self?.appState.authenticator.reset()
              self?.start()
          })
      })
      let primaryButton: ErrorAlertViewModel.ButtonModel = ("App neustarten", primaryAction)
      let errorText = """
Das Gerät wurde mit einer PIN initialisiert. Die PIN wird zum Testen wieder gelöscht da weitere Funktionalität noch nicht implementiert ist.
"""
      let model = ErrorAlertViewModel(title: "Noch nicht implementiert",
                                      alertType: .fail,
                                      header: "Noch nicht implementiert",
                                      text: errorText,
                                      buttons: [primaryButton])
      showError(viewModel: model)
  }
}
