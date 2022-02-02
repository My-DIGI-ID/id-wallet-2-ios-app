//
//  WalletTabBarController.swift
//  IDWallet
//
//  Created by Michael Utech on 12.01.22.
//

import UIKit

@MainActor
class WalletTabBarController: BareBaseViewController {
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

    private var walletController = EmptyWalletViewController()
    private var walletBarItem = UITabBarItem(
        title: "Wallet",
        image: UIImage.requiredImage(name: "BarbuttonWallet").withRenderingMode(.alwaysOriginal),
        selectedImage: UIImage.requiredImage(name: "BarbuttonWalletSelected").withRenderingMode(.alwaysOriginal))

    private var qrcodeScanController = UIViewController()
    private var qrcodeScanBarItem = UITabBarItem(
        title: "QR-Code Scan",
        image: UIImage.requiredImage(name: "BarbuttonQrcodeBig").withRenderingMode(.alwaysOriginal),
        selectedImage: UIImage.requiredImage(name: "BarbuttonQrcodeBigSelected").withRenderingMode(.alwaysOriginal))

    private var activitiesController = UIViewController()
    private var activitiesBarItem = UITabBarItem(
        title: "Aktivitäten",
        image: UIImage.requiredImage(name: "BarbuttonActivities").withRenderingMode(.alwaysOriginal),
        selectedImage: UIImage.requiredImage(name: "BarbuttonActivitiesSelected").withRenderingMode(.alwaysOriginal))

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOnce()
    }

    init() {
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
        qrcodeScanController.view.backgroundColor = .systemRed
        activitiesController.view.backgroundColor = .systemYellow

        viewControllers = [
            walletController, qrcodeScanController, activitiesController
        ]
    }
}

extension WalletTabBarController: CustomTabBarDelegate {
    func customTabBar(_ tabBar: CustomTabBar, didSelect item: UITabBarItem) {
        if let index = viewControllers.firstIndex(where: { viewController in viewController.tabBarItem == item }) {
            selectedIndex = index
        }
    }
}
