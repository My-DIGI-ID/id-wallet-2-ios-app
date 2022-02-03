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

enum ScanError: Error {
    case acesss
    case failed
}

struct ScanViewModel {
    let scannedQR = PassthroughSubject<String, ScanError>()
}

class ScannerCoordinator: Coordinator {

    let presenter: PresenterProtocol
    let scanViewModel: ScanViewModel = ScanViewModel()

    var cancellable: AnyCancellable?

    init(presenter: PresenterProtocol, completion: @escaping (Result<String, ScanError>) -> Void) {
        self.presenter = presenter

        cancellable = self.scanViewModel.scannedQR.sink(receiveCompletion: { completed in
            switch completed {
            case .failure(let error):
                completion(.failure(error))
            case .finished:
                break
            }
        }, receiveValue: { qrCode in
            completion(.success(qrCode))
        })
    }
    
    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presenter.present(QRScannerViewController(viewModel: scanViewModel))
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self = self else { return }
                if granted {
                    DispatchQueue.main.async {
                        self.presenter.present(QRScannerViewController(viewModel: self.scanViewModel))
                    }
                }
            }
        case .denied:
            let alert = UIAlertController(title: "Fehler",
                                          message: "Erlaube den Zugriff, um QR-Codes scannen zu können.",
                                          preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "Abbrechen", style: .default))
                alert.addAction(UIAlertAction(title: "Einstellungen", style: .cancel) { _ in

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
}
