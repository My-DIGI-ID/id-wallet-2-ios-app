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

fileprivate extension ImageNameIdentifier {
    static let wallet = ImageNameIdentifier(rawValue: "Wallet")
    static let walletSelected = ImageNameIdentifier(rawValue: "WalletSelected")
    static let qrBig = ImageNameIdentifier(rawValue: "QrcodeBig")
    static let qrBigSelected = ImageNameIdentifier(rawValue: "QrcodeBigSelected")
    static let activities = ImageNameIdentifier(rawValue: "Activities")
    static let activitiesSelected = ImageNameIdentifier(rawValue: "ActivitiesSelected")
}

@MainActor
class WalletTabBarController: BareBaseViewController {

    var messageViewController: WalletMessageViewController?

    var viewControllers: [UIViewController] = [] {
        didSet {
            // See tabBar.items for how selection is updated:
            tabBar.items = viewControllers.compactMap { $0.tabBarItem }
        }
    }

    var selectedIndex: Int = -1 {
        didSet {
            if selectedIndex >= 0 && selectedIndex < viewControllers.count {
                selectedViewController = viewControllers[selectedIndex]
            } else {
                selectedViewController = nil
            }
            if tabBar.selectedIndex != selectedIndex {
                tabBar.selectedIndex = selectedIndex
            }
        }
    }

    private (set) var selectedViewController: UIViewController? {
        willSet {
            guard selectedViewController != newValue else {
                return
            }

            // This will have to be looped through a coordinator/presenter that will take
            // care of the navigation in the context of the current tab, at least where
            // complex navigations take place. (This will probably end up as something like
            // TabbedPresenter/TabCoordinator). For that some points need clarification:
            // * Do we need anything but pseudo-fullscreen navigation in any tab?
            //   (f.e. uinavigationcontroller inside tab)
            // * Do we need to preserve navigation state when tabs are switched or will switch
            //   always reset the navigation state of the current tab?

            selectedViewController?.willMove(toParent: nil)
            if let viewController = newValue {
                addChild(viewController)
                contentView.addSubview(viewController.view)
                viewController.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    contentView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
                    contentView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
                    contentView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
                    contentView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
                ])
                selectedViewController?.removeFromParent()
                selectedViewController?.view.removeFromSuperview()
                viewController.didMove(toParent: self)
            } else {
                selectedViewController?.removeFromParent()
                selectedViewController?.view.removeFromSuperview()
            }
        }
    }

    private(set) var tabBar: CustomTabBar = CustomTabBar()
    private(set) var contentView: UIView = UIView()

    private var controlledConstraints: [NSLayoutConstraint] = []

    private var presenter: PresenterProtocol
    private var scannerCoordinator: ScannerCoordinator?

    private var walletController = WalletViewController()
    private var walletBarItem = UITabBarItem(
        title: "Wallet",
        image: UIImage(existing: .wallet).withRenderingMode(.alwaysOriginal),
        selectedImage: UIImage(existing: .walletSelected).withRenderingMode(.alwaysOriginal))

    private var qrcodeScanController = UIViewController()
    private var qrcodeScanBarItem = UITabBarItem(
        title: "QR-Code Scan",
        image: UIImage(existing: .qrBig).withRenderingMode(.alwaysOriginal),
        selectedImage: UIImage(existing: .qrBigSelected).withRenderingMode(.alwaysOriginal))

    private var activitiesController = UIViewController()
    private var activitiesBarItem = UITabBarItem(
        title: "Aktivitäten",
        image: UIImage(existing: .activities).withRenderingMode(.alwaysOriginal),
        selectedImage: UIImage(existing: .activitiesSelected).withRenderingMode(.alwaysOriginal))

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented, use init(presenter:)")
    }

    init(presenter: PresenterProtocol) {
        self.presenter = presenter
        super.init(style: nil)
        setupOnce()
    }

    private func setupOnce() {
        tabBar.backgroundColor = .white
        tabBar.height = 100.0
        tabBar.bottomPadding = 42.0
        tabBar.delegate = self

        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)

        controlledConstraints.append(contentsOf: [
            contentView.topAnchor.constraint(equalTo: view.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        NSLayoutConstraint.activate(controlledConstraints)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        walletController.tabBarItem = walletBarItem

        // T-O-D-O: [03/01/2022] placeholder for not yet implemented tabs (timed to do comments not yet configured)
        qrcodeScanController.tabBarItem = qrcodeScanBarItem
        activitiesController.tabBarItem = activitiesBarItem
        qrcodeScanController.view.backgroundColor = .systemBackground
        activitiesController.view.backgroundColor = .systemYellow

        viewControllers = [
            walletController, qrcodeScanController, activitiesController
        ]
    }
}

extension WalletTabBarController: CustomTabBarDelegate {
    func customTabBar(_ tabBar: CustomTabBar, didSelect item: UITabBarItem) {
        if item == qrcodeScanBarItem {
            guard
                item != selectedViewController?.tabBarItem,
                scannerCoordinator == nil
            else {
                return
            }

            let previouslySelected = selectedIndex
            scannerCoordinator = ScannerCoordinator(presenter: presenter) { result in
                switch result {
                case .success(let scanned):
                    print(scanned)
                    self.selectedIndex = 0
                    self.presenter.dismiss(options: .defaultOptions, completion: nil)
                case .failure(let error):
                    let alert = UIAlertController(title: "Fehler", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

                    self.selectedIndex = previouslySelected
                    self.presenter.presentModal(alert, options: .defaultOptions)
                    self.presenter.dismiss(options: .defaultOptions, completion: nil)
                case .cancelled:
                    self.selectedIndex = previouslySelected
                    self.presenter.dismiss(options: .defaultOptions, completion: nil)
                case .cameraPermissionDenied:
                    self.selectedIndex = previouslySelected
                    // No dismiss here, because camera permission dialog is not
                    // presented using the presenter
                case .level:
                    self.selectedIndex = previouslySelected
                    self.startErrorViewController(alertLevel: .currentValue)
                    self.presenter.dismiss(options: .defaultOptions, completion: nil)
                }

                self.scannerCoordinator = nil
            }
            scannerCoordinator?.start()
        }

        if let index = viewControllers.firstIndex(where: { viewController in viewController.tabBarItem == item }) {
            selectedIndex = index
        }
    }

    func startErrorViewController(alertLevel: AlertLevel) {
        let doneAction = UIAction { [weak self] _ in
            guard let self = self else { return }
            self.presenter.dismissModal(completion: nil)
        }

        let linkAction = UIAction { [weak self] _ in
            guard
                let self = self,
                let url = Bundle.main.url(forResource: "level-x-help", withExtension: "html"),
                let viewController = self.messageViewController
            else {
                return
            }
            let viewModel = WebViewModel(title: "Hilfe", url: url)
            viewController.present(WebViewController(viewModel: viewModel), animated: true, completion: nil)
        }

        let viewModel = MessageViewModel(
            messageType: .blocked,
            header: "request_blocked".localized,
            text: "request_blocked_message".localized,
            buttons: [
                ButtonConfig(title: "request_blocked_link".localized, image: nil, style: .link, action: linkAction),
                ButtonConfig(title: "close".localized, image: nil, action: doneAction)])

        messageViewController = WalletMessageViewController(viewModel: viewModel)
        presenter.presentModal(messageViewController!, options: .defaultOptions)
    }
}
