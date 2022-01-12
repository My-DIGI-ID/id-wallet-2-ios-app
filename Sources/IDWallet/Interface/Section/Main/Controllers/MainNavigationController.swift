//
//  MainNavigationController.swift
//  IDWallet
//
//  Created by Michael Utech on 15.12.21.
//

import UIKit

// This implementation preserves the use of the storyboard. Most coordinator users prefer
// to get rid of storyboards alltogether.
//
// We probably don't need this navigation controller and will likely replace it with a plain
// view controller.
//
// If we abandon storyboards, we will need to manually setup window and root view controller
// in appdelegate and ``AppCoordinator`` can take over from there.
class MainNavigationController: UINavigationController {
  private var appCoordinator: AppCoordinator?

  override func viewDidLoad() {
    super.viewDidLoad()

    hidesBarsOnTap = false
    hidesBarsOnSwipe = false
    setNavigationBarHidden(true, animated: false)
    setToolbarHidden(true, animated: false)
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    if appCoordinator == nil {
      appCoordinator = AppCoordinator(presenter: Presenter(self), appState: AppState())
      appCoordinator?.start()
    }
  }
}
