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
import AVFoundation
import Combine
import Aries

private enum Constants {
    enum Text {
        enum Alert {
            static let title = "error".localized
            static let message = "qr_code_request_camera_access_disabled".localized
            static let cancel = "cancel".localized
            static let settings = "settings".localized
        }
    }
}

enum ScanError: Error {
    case acesss
    case failure
    case cancelled
}

@MainActor
class ScannerCoordinator: Coordinator {
    enum Result {
        case success(_ credentialId: String)
        case failure(_ error: Error)
        case cancelled
        case cameraPermissionDenied
    }
    
    let presenter: PresenterProtocol
    private let completion: (Result) -> Void
    
    private var currentViewController: UIViewController?
    private lazy var connectionService = {
        return CustomConnectionService()
    }()
    
    init(presenter: PresenterProtocol, completion: @escaping (ScannerCoordinator.Result) -> Void) {
        self.presenter = presenter
        self.completion = completion
    }
    
    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startScan()
        case .notDetermined:
            startRequestAccess()
        case .denied:
            let alert = UIAlertController(
                title: Constants.Text.Alert.title,
                message: Constants.Text.Alert.message,
                preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: Constants.Text.Alert.cancel, style: .default) {_ in
                DispatchQueue.main.async {
                    self.completion(.cameraPermissionDenied)
                }
            })
            alert.addAction(UIAlertAction(title: Constants.Text.Alert.settings, style: .cancel) { _ in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                UIApplication.shared.open(
                    settingsURL,
                    options: [:], completionHandler: { _ in
                        self.startRequestAccess()
                    })
            })
            
            presenter.presentModal(alert, options: .init(animated: true, modalPresentationStyle: .automatic, modalTransitionStyle: .crossDissolve))
        case .restricted:
            return
        @unknown default:
            return
        }
    }
    
    func startRequestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                if granted {
                    self.startScan()
                } else {
                    self.completion(.cameraPermissionDenied)
                }
            }
        }
    }
    
    func startScan() {
        currentViewController = QRScannerViewController { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let qrCode):
                    do {
                        // self.completion(Result.success(qrCode))                        
                        let connectionService = CustomConnectionService()
                        if let result = try connectionService.invitee(for: qrCode) {
                            let (name, imageUrl) = result
                            self.startConnectionConfirmation(qrCode: qrCode, name: name, imageUrl: imageUrl)
                        }
                    } catch let error {
                        self.completion(Result.failure(error))
                    }
                    
                case .failure(let error):
                    self.completion(Result.failure(error))
                    
                case .cancelled:
                    self.completion(Result.cancelled)
                }
            }
        }
        if let currentViewController = currentViewController {
            presenter.present(currentViewController)
        }
    }
    
    func startConnectionConfirmation(
        qrCode: String,
        name: String?,
        imageUrl: String?
    ) {
        if let name = name {
            let previous = currentViewController
            let viewModel = ConnectionConfirmationViewModel(connection: name)
            
            currentViewController =
            ConnectionConfirmationViewController(viewModel: viewModel) { result in
                switch result {
                case .confirm:
                    Task {
                        do {
                            let connectionId = try await self.connectionService.connect(with: qrCode)
                            self.startOverview(
                                connectionId: connectionId,
                                name: viewModel.connection,
                                imageUrl: imageUrl
                            )
                        } catch let error {
                            print(error)
                            self.completion(.failure(error))
                        }
                    }
                case .cancel, .deny:
                    self.completion(Result.cancelled)
                }
            }
            if let currentViewController = currentViewController {
                presenter.present(currentViewController, replacing: previous)
            }
        }
    }
    
    func startOverview(connectionId: String, name: String?, imageUrl: String?) {
        Task(priority: .userInitiated) {
            let credentialId: String
            let preview: CredentialPreview
            
            do {
                let pair = try await CustomCredentialService().preview(for: connectionId)
                credentialId = pair.0
                preview = pair.1
            } catch {
                print(error)
                return
            }
            
            let rows: [OverviewViewModel.DataRow] = preview.attributes.map {
                ($0.name, $0.value)
            }
            
            let viewModel = OverviewViewModel(
                header: "Mesa Deutschland GmbH",
                subHeader: "16.02.2021 - 15:20 Uhr",
                title: "Arbeitgeberbescheinigung",
                imageURL: imageUrl ?? "https://digital-enabling.eu/assets/images/logo.png",
                buttons: [
                    ("Zur Wallet hinzufügen", UIAction { [weak self] _ in
                        guard let self = self else {
                            return
                        }
                        Task {
                            do {
                                let credentialId = try await CustomCredentialService().request(with: credentialId)
                                self.startSuccessViewController(credentialId: credentialId)
                            } catch let error {
                                self.completion(.failure(error))
                            }
                        }
                    }),
                    ("Abbrechen", UIAction { _ in
                        self.completion(.cancelled)
                    })],
                data: rows)
            
            let previous = currentViewController
            currentViewController = OverviewViewController(viewModel: viewModel, completion: {
                self.completion(.cancelled)
            })
            if let currentViewController = currentViewController {
                presenter.present(currentViewController, replacing: previous)
            }
        }
    }
    
    func startSuccessViewController(credentialId: String) {
        let doneAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.completion(.success(credentialId))
            self.presenter.dismissModal(completion: nil)
        }
        
        let viewModel = MessageViewModel(
            messageType: .success,
            header: "Daten erfolgreich übermittelt",
            buttons: [("Fertig", doneAction)])
        
        presenter.presentModal(WalletMessageViewController(viewModel: viewModel), options: .defaultOptions)
    }
}
