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

class OverviewCoordinator: Coordinator {
    let presenter: PresenterProtocol
    
    init(presenter: PresenterProtocol) {
        self.presenter = presenter
    }
    
    func start() {
        let addAction = UIAction { _ in
            self.presenter.dismissModal(completion: nil)
        }
        let cancelAction = UIAction { _ in
            self.presenter.dismissModal(completion: nil)
        }
        
        let rows: [OverviewViewModel.DataRow] = [
            ("Stadt", "Musterhausen"),
            ("Firmenname", "MESA Deutschland"),
            ("Straße", "Musterstraße 5"),
            ("Abteilung", "-"),
            ("Vorname", "Max"),
            ("Nachname", "Mustermann")]
        
        let viewModel = OverviewViewModel(
            header: "Mesa Deutschland GmbH",
            subHeader: "16.02.2021 - 15:20 Uhr",
            title: "Arbeitgeberbescheinigung",
            imageURL: "https://digital-enabling.eu/assets/images/logo.png",
            buttons: [
                ("Zur Wallet hinzufügen", addAction),
                ("Abbrechen", cancelAction)], data: rows)
        presenter.presentModal(OverviewViewController(viewModel: viewModel), options: .defaultOptions)
    }
}
