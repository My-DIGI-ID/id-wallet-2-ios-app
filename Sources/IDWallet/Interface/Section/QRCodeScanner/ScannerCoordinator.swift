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

struct ScanViewModel {
    let scannedQR = PassthroughSubject<String, ScanError>()
}

@MainActor
class ScannerCoordinator: Coordinator {
    enum Result {
        case success(_ credentialId: String)
        case failure(_ error: Error)
        case cancelled
    }

    let presenter: PresenterProtocol
    let scanViewModel: ScanViewModel = ScanViewModel()
    private let completion: (Result) -> Void

    private var cancellable: AnyCancellable?
    private var currentViewController: UIViewController?

    init(presenter: PresenterProtocol, completion: @escaping (Any) -> Void) {
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

            alert.addAction(UIAlertAction(title: Constants.Text.Alert.cancel, style: .default))
            alert.addAction(UIAlertAction(title: Constants.Text.Alert.settings, style: .cancel) { _ in

                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsURL,
                                          options: [:], completionHandler: nil)
            })

            presenter.present(alert)
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

            if granted {
                DispatchQueue.main.async {
                    self.startScan()
                }
            }
        }
    }

    func startScan() {
        cancellable = self.scanViewModel.scannedQR.sink(receiveCompletion: { completed in
            switch completed {
            case .failure(let error):
                self.completion(Result.failure(error))
            case .finished:
                break
            }
        }, receiveValue: { [self] qrCode in
            do {
                // self.completion(Result.success(qrCode))

                let connectionService = CustomConnectionService()
                if let result = try connectionService.invitee(for: qrCode) {
                    let (name, imageUrl) = result
                    self.startConnectionConfirmation(qrCode: qrCode, name: name, imageUrl: imageUrl, viewController: self.currentViewController!)
                }
            } catch let error {
                self.completion(Result.failure(error))
            }
        })

        currentViewController = QRScannerViewController(viewModel: scanViewModel)
        presenter.present(currentViewController!)
    }

    func startConnectionConfirmation(qrCode: String, name: String?, imageUrl: String?, viewController previous: UIViewController) {
        if let name = name {
            var viewController: ConnectionConfirmationViewController?
            let viewModel = ConnectionConfirmationViewModel(
                connection: name,
                buttons: [
                    (
                        "Erlauben",
                        UIAction(handler: { _ in
                            Task {
                                let connectionService = CustomConnectionService()
                                let connectionId = try await connectionService.connect(with: qrCode)

                                self.startOverview(connectionId: connectionId, name: name, imageUrl: imageUrl, viewController: self.currentViewController!)
                            }
                        })
                    ),
                    (
                        "Abbrechen",
                        UIAction(handler: { _ in
                            self.completion(Result.cancelled)
                        })
                    )
                ]
            )
            currentViewController = ConnectionConfirmationViewController(viewModel: viewModel)
            presenter.present(currentViewController!, replacing: previous)
        }
    }

    func startOverview(connectionId: String, name: String?, imageUrl: String?, viewController previous: UIViewController) {

        let rows: [OverviewViewModel.DataRow] = [
            ("Stadt", "Musterhausen"),
            ("Firmenname", "MESA Deutschland"),
            ("Straße", "Musterstraße 5"),
            ("Abteilung", "-"),
            ("Vorname", "Max"),
            ("Nachname", "Mustermann")]

        let credentialService = CustomCredentialService()

        let viewModel = OverviewViewModel(
            header: name ?? "Mesa Deutschland GmbH",
            subHeader: "16.02.2021 - 15:20 Uhr",
            title: "Arbeitgeberbescheinigung",
            imageURL: imageUrl ?? "https://digital-enabling.eu/assets/images/logo.png",
            buttons: [
                ("Zur Wallet hinzufügen", UIAction { _ in
                    Task {
                        do {
                            let credentialId = try await credentialService.request(with: connectionId)
                            self.completion(.success(credentialId))
                        } catch let error {
                            self.completion(.failure(error))
                        }
                    }
                }),
                ("Abbrechen", UIAction { _ in
                    self.completion(.cancelled)
                })],
            data: rows)

        presenter.present(OverviewViewController(viewModel: viewModel), replacing: previous)
    }
}
