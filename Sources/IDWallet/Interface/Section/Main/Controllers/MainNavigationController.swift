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

import UIKit

// This implementation preserves the use of the storyboard.
//
// If we abandon storyboards, we will need to manually setup window and root view controller
// in appdelegate and ``AppCoordinator`` can take over from there.

class MainNavigationController: UINavigationController {
    private lazy var appCoordinator: AppCoordinator = {
        AppCoordinator(presenter: rootPresenter, appState: AppState())
    }()

    private lazy var rootPresenter = {
        RootPresenter(self)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        hidesBarsOnTap = false
        hidesBarsOnSwipe = false
        setNavigationBarHidden(true, animated: false)
        setToolbarHidden(true, animated: false)

        rootPresenter.present(BackgroundViewController(), options: .notAnimated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appCoordinator.start()
    }
}
