//
//  OnboardingViewController.swift
//  IDWallet
//
//  Created by Michael Utech on 11.12.21.
//

// swiftlint:disable file_length
// swiftlint:disable function_body_length

import Combine
import SwiftUI
import UIKit

extension OnboardingViewController {
    
    /// See ``BaseViewID``
    enum ViewID: String, BaseViewID {
        case containerView
        case pageControl
        case pageContainerView
        case pageViewControllerView
        case startButton
        case showInfoButton
        
        var key: String { return rawValue }
    }
    
    struct Style: BaseViewControllerStyle {
        static let regular = Style()
        
        let themeContext: ThemeContext
        let layout: Layout
        
        init(themeContext: ThemeContext, layout: Layout? = nil) {
            self.themeContext = themeContext
            self.layout = layout ?? defaultOrCompressed(.regular, .compressed)
        }
        init() {
            self.init(themeContext: .alternative)
        }
    }
    
    struct Layout: BaseViewControllerLayout {
        static let regular = Layout(
            views: [
                .containerView: .init(
                    // Required: container view fills super view
                    // top and bottom can be configured
                    padding: Padding(0, top: 76, bottom: 60)
                )
            ],
            verticalSpacing: .equal(40),
            verticalSpacingPageControl: .equal(5)
        )
        static let compressed = Layout(
            views: [
                .containerView: .init(
                    // Required: container view fills super view
                    // top and bottom can be configured
                    padding: Padding(0, top: 40.0, bottom: 20.0)
                )
            ],
            verticalSpacing: .equal(36),
            verticalSpacingPageControl: .equal(5)
        )
        
        let views: ViewsLayout<ViewID>
        let verticalSpacing: [LayoutPredicate]
        let verticalSpacingPageControl: [LayoutPredicate]
        
        var metrics: [String: Any] {
            [
                "vSpacing": verticalSpacing,
                "vSpacingPageControl": verticalSpacingPageControl
            ]
        }
    }
    // MARK: -
    
    class ViewModel {
        static func pageViewModels(
            themeContext: ThemeContext
        ) -> [OnboardingPageViewController.ViewModel] {
            return [
                OnboardingPageViewController.ViewModel(
                    image: themeContext.images.onboardingPage1,
                    heading: NSLocalizedString(
                        "Die persönliche digitale Brieftasche für alle",
                        comment: "Onboarding Page 1 Heading"),
                    subHeading: NSLocalizedString(
                        "Ausweise, Dokumente und Nachweise der ID Wallet hinzufügen und immer griffbereit haben.",
                        comment: "Onboarding Page 1 Sub Heading")
                ),
                OnboardingPageViewController.ViewModel(
                    image: themeContext.images.onboardingPage2,
                    heading: NSLocalizedString(
                        "Daten sicher aufbewahren",
                        comment: "Onboarding Page 2 Heading"),
                    subHeading: NSLocalizedString(
                        "Alle Daten werden verschlüsselt gesichert und können jederzeit von Dir gelöscht werden. " +
                        "Du entscheidest mit wem welche Daten geteilt werden sollen.",
                        comment: "Onboarding Page 2 Sub Heading")
                ),
                OnboardingPageViewController.ViewModel(
                    image: themeContext.images.onboardingPage3,
                    heading: NSLocalizedString(
                        "Mit der ID Wallet einfach und sicher digital ausweisen",
                        comment: "Onboarding Page 3 Heading"),
                    subHeading: NSLocalizedString(
                        "Zum Beispiel beim digitalen Hotel-Check-In oder beim Beantragen Deiner neuen SIM-Karte.",
                        comment: "Onboarding Page 3 Sub Heading")
                )
            ]
        }
        @Published var pageViewModels: [OnboardingPageViewController.ViewModel] {
            didSet {
                if currentPageIndex >= pageViewModels.count {
                    currentPageIndex = UInt(pageViewModels.count - 1)
                }
            }
        }
        @Published var currentPageIndex: UInt = 0
        @Published var commitButtonTitle: String = NSLocalizedString(
            "ID Wallet einrichten", comment: "Commit Button Title")
        @Published var canCommit: Bool = true
        let commit: (OnboardingViewController) -> Void
        @Published var showInfoButtonTitle: String = NSLocalizedString(
            "Mehr erfahren", comment: "Show Info Button Title")
        @Published var canShowInfo: Bool = true
        let showInfo: (OnboardingViewController) -> Void
        init(
            commit: @escaping (OnboardingViewController) -> Void,
            showInfo: @escaping (OnboardingViewController) -> Void,
            themeContext: ThemeContext = .alternative,
            pageViewModels: [OnboardingPageViewController.ViewModel]? = nil
        ) {
            self.commit = commit
            self.showInfo = showInfo
            self.pageViewModels = pageViewModels ?? Self.pageViewModels(themeContext: themeContext)
        }
    }
}

// MARK: -

class OnboardingViewController: BaseViewController<
OnboardingViewController.ViewID, OnboardingViewController.Style,
OnboardingViewController.ViewModel
>,
UIPageViewControllerDelegate,
UIPageViewControllerDataSource {
    
    // MARK: - Storage
    
    var pageViewController: UIPageViewController? {
        willSet {
            guard pageViewController != newValue else {
                ContractError.guardAssertionFailed(
                    "Reinitialisation of the same page view controller hints at a flawed initialization process."
                ).fatal()
            }
            guard pageViewController == nil || newValue == nil else {
                ContractError.guardAssertionFailed(
                    "Page view controller has not been properly deinitialized"
                ).fatal()
                // otherwise it would be nil before a new one is assigned
            }
        }
    }
    
    // MARK: - Views
    
    override func createOrUpdateViews() {
        super.createOrUpdateViews()
        
        var didCreate = false
        
        style.themeContext.applyPageBackgroundStyles(view: view)
        makeOrUpdateContainer(
            id: .containerView,
            in: view, didMake: &didCreate
        ) { [self] containerView, didCreate in
            containerView.translatesAutoresizingMaskIntoConstraints = false
            makeOrUpdatePageControl(
                id: .pageControl,
                in: containerView, didMake: &didCreate
            ) { pageControl in
                pageControl.translatesAutoresizingMaskIntoConstraints = false
            }
            
            makeOrUpdateContainer(
                id: .pageContainerView,
                in: containerView, didMake: &didCreate
            ) { pageContainerView, didCreate in
                pageContainerView.translatesAutoresizingMaskIntoConstraints = false
                
                if pageViewController == nil {
                    pageViewController = UIPageViewController(
                        transitionStyle: .scroll,
                        navigationOrientation: .horizontal,
                        options: nil)
                    addChild(pageViewController!)
                    addControlledView(
                        .pageViewControllerView,
                        view: pageViewController!.view,
                        in: pageContainerView)
                    pageViewController?.didMove(toParent: self)
                    didCreate = true
                }
                guard let view = pageViewController?.view else {
                    ContractError.guardAssertionFailed().fatal()
                }
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            
            makeOrUpdatePrimaryActionButton(
                id: .startButton, title: viewModel.commitButtonTitle,
                isEnabled: viewModel.canCommit,
                in: containerView, didMake: &didCreate
            ) { startButton in
                startButton.translatesAutoresizingMaskIntoConstraints = false
            }
            makeOrUpdateExternalLinkButton(
                id: .showInfoButton, title: viewModel.showInfoButtonTitle,
                isEnabled: viewModel.canShowInfo,
                in: containerView, didMake: &didCreate
            ) { showInfoButton in
                showInfoButton.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        if didCreate {
            resetConstraints()
            view.setNeedsUpdateConstraints()
        }
    }
    
    override func resetViews() {
        if let pageViewController = pageViewController {
            pageViewController.willMove(toParent: nil)
            pageViewController.view.removeFromSuperview()
            pageViewController.removeFromParent()
            // pageViewController.view is handled by super implementation
            self.pageViewController = nil
        }
        
        super.resetViews()
    }
    
    // MARK: - Layout
    
    override func createOrUpdateConstraints() {
        super.createOrUpdateConstraints()
        
        guard !hasControlledConstraints else { return }
        
        // Apply layout parameters from style.layout.views
        // Expects:
        // - padding in style.layout.views[.containerView] covering all sides
        addConstraintsForViewsLayout()
        
        // guard let containerView = controlledView(.containerView) else { reportFatalBug() }
        // addConstraintsFillingSuperview(view: containerView)
        
        guard let pageViewControllerView = controlledView(.pageViewControllerView) else {
            ContractError.guardAssertionFailed().fatal()
        }
        pageViewControllerView.translatesAutoresizingMaskIntoConstraints = false
        addConstraintsFillingSuperview(view: pageViewControllerView)
        
        guard let pageContainerView = controlledView(.pageContainerView) else {
            ContractError.guardAssertionFailed().fatal()
        }
        
        pageContainerView.translatesAutoresizingMaskIntoConstraints = false
        addConstraintsForPadding(.init(horizontal: 0), view: pageContainerView)
        
        // Align vertically and center horizontally
        let vspcPC = style.layout.verticalSpacingPageControl.vfl ?? "-0-"
        let vspc = style.layout.verticalSpacing.vfl ?? "-0-"
        addConstraints(
            withVisualFormat:
                "V:|-0-[\(ViewID.pageControl)]\(vspcPC)[\(ViewID.pageContainerView)]\(vspc)" +
            "[\(ViewID.startButton)]\(vspc)[\(ViewID.showInfoButton)]-0-|",
            options: .alignAllCenterX,
            views: viewsForLayout, identifier: "vertical"
        )
        
        // Center startButton with super view, anchoring the vertical group
        guard let startButton = controlledView(.startButton) else {
            ContractError.guardAssertionFailed().fatal()
        }
        addConstraint(
            startButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor), identifier: "centerX")
    }
    
    // MARK: - Bindings
    
    var pageViewControllers: [OnboardingPageViewController] = []
    var lastDisplayedPage: UInt?
    var pendingPageIndex: UInt?
    
    override func activateBindings() {
        if let pageViewController = pageViewController,
           let startButton = controlledView(.startButton) as? UIButton,
           let showInfoButton = controlledView(.showInfoButton) as? UIButton,
           let pageControl = controlledView(.pageControl) as? UIPageControl {
            super.activateBindings()
            
            bind(
                activate: {
                    pageViewController.delegate = self
                    pageViewController.dataSource = self
                },
                deactivate: { [weak self] in
                    self?.pageViewController?.delegate = nil
                    self?.pageViewController?.dataSource = nil
                    self?.pageViewControllers = []
                    self?.lastDisplayedPage = nil
                    self?.pendingPageIndex = nil
                }
            )
            bind(subscriptions: [
                viewModel.$pageViewModels.sink { [weak self] models in
                    if let self = self {
                        let pvStyle = OnboardingPageViewController.Style(themeContext: self.style.themeContext)
                        self.pageViewControllers = models.map { model in
                            let result = OnboardingPageViewController(style: pvStyle, viewModel: model)
                            return result
                        }
                        pageControl.numberOfPages = models.count
                    }
                },
                viewModel.$currentPageIndex.sink { [weak self] current in
                    if let self = self {
                        if current != self.lastDisplayedPage && current < self.pageViewControllers.count {
                            let pageVC = self.pageViewControllers[Int(current)]
                            let direction: UIPageViewController.NavigationDirection =
                            (current >= (self.lastDisplayedPage ?? current) ? .forward : .reverse)
                            self.pageViewController?.setViewControllers(
                                [pageVC], direction: direction, animated: true)
                            self.lastDisplayedPage = current
                        }
                        pageControl.currentPage = Int(current)
                    }
                }
            ])
            if let current = lastDisplayedPage, current < pageViewControllers.count {
                pageViewController.setViewControllers(
                    [self.pageViewControllers[Int(current)]],
                    direction: .forward,
                    animated: true)
            }
            bind(
                control: pageControl, target: self, action: #selector(setCurrentPage(sender:)),
                for: .valueChanged)
            bind(
                control: startButton, target: self, action: #selector(start(sender:)), for: .touchUpInside)
            bind(
                control: showInfoButton, target: self, action: #selector(showInfo(sender:)),
                for: .touchUpInside)
        }
    }
    @objc func setCurrentPage(sender: UIPageControl) {
        let current = sender.currentPage
        if current >= 0 && current < viewModel.pageViewModels.count {
            viewModel.currentPageIndex = UInt(current)
        }
    }
    @objc func start(sender: UIButton) {
        if viewModel.canCommit {
            viewModel.commit(self)
        }
    }
    @objc func showInfo(sender: UIButton) {
        if viewModel.canShowInfo {
            viewModel.showInfo(self)
        }
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        if let pageVC = viewController as? OnboardingPageViewController,
           let index = self.pageViewControllers.firstIndex(of: pageVC),
           index > 0 {
            return self.pageViewControllers[index - 1]
        }
        return nil
    }
    func pageViewController(
        _ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        if let pageVC = viewController as? OnboardingPageViewController,
           let index = self.pageViewControllers.firstIndex(of: pageVC),
           index + 1 < self.pageViewControllers.count {
            return self.pageViewControllers[index + 1]
        }
        return nil
    }
    
    // MARK: Page View Controller Delegate
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        if pendingViewControllers.count == 1,
           let pageVC = pendingViewControllers[0] as? OnboardingPageViewController,
           let index = self.pageViewControllers.firstIndex(of: pageVC) {
            self.pendingPageIndex = UInt(index)
            if let pageControl = controlledView(.pageControl) as? UIPageControl {
                pageControl.currentPage = index
            }
        }
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController], transitionCompleted completed: Bool
    ) {
        if completed,
           let pendingIndex = self.pendingPageIndex,
           let viewModel = viewModel {
            self.pendingPageIndex = nil
            self.lastDisplayedPage = pendingIndex
            viewModel.currentPageIndex = pendingIndex
        } else if !completed,
                  let last = self.lastDisplayedPage,
                  let pageControl = controlledView(.pageControl) as? UIPageControl {
            pageControl.currentPage = Int(last)
        }
    }
}
