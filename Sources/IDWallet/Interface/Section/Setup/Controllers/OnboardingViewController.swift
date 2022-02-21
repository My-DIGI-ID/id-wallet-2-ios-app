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

import Combine
import UIKit

// MARK: - Configuration

private enum Constants {
    enum Styles {
        static let backgroundColor: UIColor = .white
        static let pageIndicatorTintColor: UIColor = .grey3
        static let currentPageIndicatorTintColor: UIColor = .primaryBlue
    }

    enum Layout {
        static let actionButtonMinWidth = 200.0
        
        enum Padding {
            static let horizontal = 25.0
            static let vContainerToControl = 19
            static let vControlToButton = 49
            static let vButtonToInfo = 14
            static let vInfoToTrailing = 38
        }
    }
}

fileprivate extension ImageNameIdentifier {
    static let onboardingPage1 = ImageNameIdentifier(rawValue: "Onboarding1")
    static let onboardingPage2 = ImageNameIdentifier(rawValue: "Onboarding2")
    static let onboardingPage3 = ImageNameIdentifier(rawValue: "Onboarding3")
}

// MARK: - Onboarding View Controller
final class OnboardingViewController: BareBaseViewController {
    fileprivate typealias Styles = Constants.Styles
    fileprivate typealias Layout = Constants.Layout
    fileprivate typealias Padding = Constants.Layout.Padding

    // MARK: - Components

    /// The view controller showing the swipable pages
    lazy var pageViewController: UIPageViewController = {
        let result = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil)
        
        result.didMove(toParent: self)
        result.delegate = self
        result.dataSource = self

        return result
    }()

    /// Wrapper hosting the view controllers content
    lazy var containerView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.containerView.key
        return result
    }()

    /// Paging view (displaying three dots)
    lazy var pageControl: UIPageControl = {
        let result = UIPageControl()

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.pageControl.key

        result.numberOfPages = viewModel.pageViewControllers.count
        result.currentPage = Int(viewModel.currentPageIndex)

        result.pageIndicatorTintColor = Styles.pageIndicatorTintColor
        result.currentPageIndicatorTintColor = Styles.currentPageIndicatorTintColor

        return result
    }()

    /// Primary button starting the device initialization
    lazy var startButton: WalletButton = {
        // see viewWillAppear for action binding
        let result = WalletButton(
            titleText: "",
            image: nil,
            imageAlignRight: false,
            style: .primary)

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.startButton.key

        return result
    }()

    /// Link button showing additional information (help viewer)
    lazy var showInfoButton: WalletButton = {
        // see viewWillAppear for action binding
        let result = WalletButton(
            titleText: NSLocalizedString(
                "Mehr erfahren", comment: "Show Info Button Title"),
            image: UIImage(systemName: "arrow.up.right")?.withSize(targetSize: CGSize(width: 14, height: 14)),
            imageAlignRight: true,
            style: .link)

        result.translatesAutoresizingMaskIntoConstraints = false
        result.accessibilityIdentifier = ViewID.showInfoButton.key

        result.style = .link

        return result
    }()

    // MARK: - State

    private let viewModel: ViewModel

    private let completion: ((OnboardingViewController) -> Void)?

    var subscriptions: [AnyCancellable] = []

    private var lastDisplayedPage: UInt?
    private var pendingPageIndex: UInt?

    // MARK: - Initialization

    init(viewModel: ViewModel, completion: ((OnboardingViewController) -> Void)? = nil) {
        self.viewModel = viewModel
        self.completion = completion
        super.init(style: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported. Use init(viewModel:completion:) instead")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Styles.backgroundColor
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        subscriptions = [
            viewModel.$currentPageIndex.sink { [weak self] current in
                if let self = self {
                    let pageViewControllers = self.viewModel.pageViewControllers
                    if current != self.lastDisplayedPage && current < pageViewControllers.count {
                        let pageVC = pageViewControllers[Int(current)]
                        let direction: UIPageViewController.NavigationDirection = (
                            current >= (self.lastDisplayedPage ?? current)
                            ? .forward
                            : .reverse
                        )
                        self.pageViewController.setViewControllers(
                            [pageVC], direction: direction, animated: true)
                        self.lastDisplayedPage = current
                    }
                    self.pageControl.currentPage = Int(current)

                    if let current = self.lastDisplayedPage, current < pageViewControllers.count {
                        self.pageViewController.setViewControllers(
                            [pageViewControllers[Int(current)]],
                            direction: .forward,
                            animated: true)
                    }
                }
            },
            
            viewModel.showInfoHidden.sink { isHidden in self.showInfoButton.isHidden = isHidden },
            viewModel.actionButtonTitle.sink { title in self.startButton.titleText = title }
        ]

        pageControl.addTarget(self, action: #selector(setCurrentPage(sender:)), for: .valueChanged)
        startButton.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
        showInfoButton.addTarget(self, action: #selector(showInfoButtonTapped(sender:)), for: .touchUpInside)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        subscriptions.forEach { subscription in subscription.cancel() }
        subscriptions.removeAll()

        pageControl.removeTarget(self, action: #selector(setCurrentPage(sender:)), for: .valueChanged)
        startButton.removeTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
        showInfoButton.removeTarget(self, action: #selector(showInfoButtonTapped(sender:)), for: .touchUpInside)
    }

    // MARK: - Layout
    private func setupLayout() {
        guard let pageViewControllerView = pageViewController.view else {
            return
        }
        
        addChild(pageViewController)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)
        
        view.addSubview(pageViewControllerView)
        view.addSubview(pageControl)
        view.addSubview(startButton)
        view.addSubview(showInfoButton)
        
        let constraints = [
            "H:|-(hPad)-[pageContainer]-(hPad)-|",
            "H:|[pageControl]|",
            "H:|[showInfo]|",
            
            "V:[pageContainer]-(vContCtrl)-[pageControl]-(vCtrlBtn)-[start]-(vBtnInfo)-[showInfo]-(vInfoTrailing)-|"
        ].constraints(with: [
            "pageContainer": pageViewControllerView,
            "pageControl": pageControl,
            "showInfo": showInfoButton,
            "start": startButton,
        ], metrics: [
            "hPad": Padding.horizontal,
            "vContCtrl": Padding.vContainerToControl,
            "vCtrlBtn": Padding.vControlToButton,
            "vBtnInfo": Padding.vButtonToInfo,
            "vInfoTrailing": Padding.vInfoToTrailing,
        ]) + [
            startButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.actionButtonMinWidth),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            showInfoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Note: Presenter should ensure that we are layout relative to the saveArea
            // For now, we use the guide manually.
            pageViewControllerView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
        ]
            
        constraints.activate()
    }

    // MARK: - Actions

    @objc
    func setCurrentPage(sender: UIPageControl) {
        let current = sender.currentPage
        if current >= 0 && current < viewModel.pageViewModels.count {
            viewModel.currentPageIndex = UInt(current)
        }
    }

    @objc
    func actionButtonTapped(sender _: UIButton) {
        if viewModel.isOnLastPage {
            completion?(self)
        } else {
            viewModel.currentPageIndex = max(0, min(
                UInt(Int(viewModel.pageViewControllers.count) - 1),
                viewModel.currentPageIndex + 1))
        }
    }

    @objc
    func showInfoButtonTapped(sender _: UIButton) {
        viewModel.showInfo(self)
    }
}

extension OnboardingViewController {
    enum ViewID: String, BaseViewID {
        case containerView
        case pageControl
        case pageContainerView
        case startButton
        case showInfoButton

        var key: String { return rawValue }
    }

    class ViewModel {
        static let pageViewModels = [
            OnboardingPageViewController.ViewModel(
                image: UIImage(identifiedBy: .onboardingPage1),
                heading: NSLocalizedString(
                    "Deine persönliche digitale Brieftasche",
                    comment: "Onboarding Page 1 Heading"),
                subHeading: NSLocalizedString(
                    "Ausweise, Dokumente und Nachweise digital speichern — " +
                    "zum Beispiel beim digitalen Hotel Check-In oder beim Kauf einer Prepaid SIM-Karte.",
                    comment: "Onboarding Page 1 Sub Heading")
            ),
            OnboardingPageViewController.ViewModel(
                image: UIImage(identifiedBy: .onboardingPage2),
                heading: NSLocalizedString(
                    "Deine Daten, sicher aufbewahrt",
                    comment: "Onboarding Page 2 Heading"),
                subHeading: NSLocalizedString(
                    "Deine Nachweise werden nur lokal auf deinem Smartphone gespeichert. " +
                    "Sie sind verschlüsselt gesichert, durch deinen Zugangscode geschützt " +
                    "und können jederzeit von dir gelöscht werden.",
                    comment: "Onboarding Page 2 Sub Heading")
            ),
            OnboardingPageViewController.ViewModel(
                image: UIImage(identifiedBy: .onboardingPage3),
                heading: NSLocalizedString(
                    "Starke Partner mit Vertrauen",
                    comment: "Onboarding Page 3 Heading"),
                subHeading: NSLocalizedString(
                    "Die Bundesregierung und die größten deutschen Unternehmen arbeiten zusammen daran, " +
                    "dass du ID in Zukunft für immer mehr Anwendungen einsetzen kannst.",
                    comment: "Onboarding Page 3 Sub Heading")
            )
        ]

        private let nextPageButtonTitle = NSLocalizedString(
            "Weiter", comment: "Next page button title")
        private let commitButtonTitle = NSLocalizedString(
            "ID Wallet einrichten", comment: "Commit button title")

        private(set) var pageViewModels: [OnboardingPageViewController.ViewModel] {
            didSet {
                if currentPageIndex >= pageViewModels.count {
                    currentPageIndex = UInt(pageViewModels.count - 1)
                }
            }
        }

        lazy var pageViewControllers = {
            pageViewModels.map { model in
                return OnboardingPageViewController(viewModel: model)
            }
        }()

        var isOnLastPage: Bool { currentPageIndex == pageViewControllers.count - 1 }

        @Published var currentPageIndex: UInt = 0

        lazy var actionButtonTitle: AnyPublisher<String, Never> = {
            $currentPageIndex.map { index in
                return index == self.pageViewControllers.count - 1
                ? self.commitButtonTitle
                : self.nextPageButtonTitle
            }.eraseToAnyPublisher()
        }()

        lazy var showInfoHidden: AnyPublisher<Bool, Never> = {
            $currentPageIndex.map { index in
                return index < self.pageViewControllers.count - 1
            }.eraseToAnyPublisher()
        }()

        @Published var canShowInfo: Bool = true
        let showInfo: (OnboardingViewController) -> Void

        init(
            modalPresenter: ModalPresenterProtocol,
            pageViewModels: [OnboardingPageViewController.ViewModel]? = nil
        ) {
            // FIXME: This should not be here. The ViewModel has no responsibility over VC logic whatsoever
            self.showInfo = { _ in
                guard let url = Bundle.main.url(
                    forResource: "learn-more-de",
                    withExtension: "html")
                else {
                    return
                }

                let viewModel = WebViewModel(title: "Mehr erfahren", url: url)
                let webViewController = WebViewController(viewModel: viewModel)

                modalPresenter.presentModal(
                    webViewController,
                    options: .init(
                        animated: true,
                        modalPresentationStyle: .pageSheet,
                        modalTransitionStyle: .coverVertical))
            }
            self.pageViewModels = pageViewModels ?? Self.pageViewModels
        }
    }
}

// MARK: - UIPageViewControllerDelegate and -DataSource
extension OnboardingViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    // MARK: - Page View Controller Data Source
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        let pageViewControllers = self.viewModel.pageViewControllers
        if  let pageVC = viewController as? OnboardingPageViewController,
            let index = pageViewControllers.firstIndex(of: pageVC),
            index > 0 {
            return pageViewControllers[index - 1]
        }
        return nil
    }

    func pageViewController(
        _ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        let pageViewControllers = self.viewModel.pageViewControllers
        if  let pageVC = viewController as? OnboardingPageViewController,
            let index = pageViewControllers.firstIndex(of: pageVC),
            index + 1 < pageViewControllers.count {
            return pageViewControllers[index + 1]
        }
        return nil
    }
    
    // MARK: Page View Controller Delegate
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        let pageViewControllers = self.viewModel.pageViewControllers
        if
            pendingViewControllers.count == 1,
            let pageVC = pendingViewControllers[0] as? OnboardingPageViewController,
            let index = pageViewControllers.firstIndex(of: pageVC) {
            self.pendingPageIndex = UInt(index)
            pageControl.currentPage = index
        }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if completed, let pendingIndex = self.pendingPageIndex {
            self.pendingPageIndex = nil
            self.lastDisplayedPage = pendingIndex
            viewModel.currentPageIndex = pendingIndex
        } else if !completed, let last = self.lastDisplayedPage {
            pageControl.currentPage = Int(last)
        }
    }
}
