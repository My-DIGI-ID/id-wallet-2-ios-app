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

class HelpViewCoordinator: Coordinator {
    private let presenter: PresenterProtocol
    private let viewModel: WebViewViewModelProtocol
    
    init(presenter: PresenterProtocol, model: WebViewViewModelProtocol) {
        self.presenter = presenter
        self.viewModel = model
    }
    
    func start() {
        presenter.presentModal(
            WebViewController(viewModel: viewModel),
            options: .init(
                animated: true,
                modalPresentationStyle: .formSheet,
                modalTransitionStyle: .coverVertical
            )
        )
    }
}
