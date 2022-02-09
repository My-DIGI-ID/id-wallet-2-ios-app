//
//  OnboardingPageVC.swift
//  IDWallet
//
//  Created by Michael Utech on 14.12.21.
//

import CocoaLumberjackSwift
import UIKit

extension OnboardingPageViewController {
    enum ViewID: String, BaseViewID {
        case containerView
        case contentWrapper
        case imageView
        case headingLabel
        case subHeadingLabel
        
        var key: String { return rawValue }
    }
    
    struct Style: BaseViewControllerStyle {
        static let regular = Style()
        let themeContext: ThemeContext
        let layout: Layout
        
        init(themeContext: ThemeContext, layout: Layout? = nil) {
            self.themeContext = themeContext
            self.layout = layout ?? defaultOrCompressed(Layout.regular, Layout.compressed)
        }
        
        init() {
            self.init(themeContext: .alternative)
        }
    }
    
    struct Layout: BaseViewControllerLayout {
        // Layout for devices w/ height >= 750
        static let regular = Layout(
            views: [
                .headingLabel: .init(
                    // Can be tweaked to enforce line breaks
                    size: .init(width: .equal(320, 751))
                ),
                .subHeadingLabel: .init(
                    // Can be tweaked to enforce line breaks
                    size: .init(width: .equal(320, 751))
                )
            ],
            
            // Spacing between icon and heading, as per sketch
            verticalSpacing: .equal(40),
            
            // Spacing between heading and sub-heading, as per sketch
            verticalTextSpacing: .equal(18)
        )
        
        // Layout for devices w/ height < 750
        static let compressed = Layout(
            views: [
                .headingLabel: .init(
                    // Can be tweaked to enforce line breaks
                    size: .init(width: .equal(320, 751))
                ),
                .subHeadingLabel: .init(
                    // Can be tweaked to enforce line breaks
                    size: .init(width: .equal(320, 751))
                )
            ],
            
            // Spacing between icon and heading (<= iPhone8)
            verticalSpacing: .equal(20),
            
            // Spacing between heading and sub-heading (<= iPhone8))
            verticalTextSpacing: .equal(16)
        )
        
        let views: ViewsLayout<ViewID>
        let verticalSpacing: [LayoutPredicate]
        let verticalTextSpacing: [LayoutPredicate]
    }
    class ViewModel {
        let image: UIImage
        let heading: String
        let subHeading: String
        init(image: UIImage, heading: String, subHeading: String) {
            self.image = image
            self.heading = heading
            self.subHeading = subHeading
        }
    }
}

class OnboardingPageViewController: BaseViewController<
OnboardingPageViewController.ViewID,
OnboardingPageViewController.Style,
OnboardingPageViewController.ViewModel
> {
    
    // MARK: - Views
    override func createOrUpdateViews() {
        super.createOrUpdateViews()
        
        var didCreate = false
        
        style.themeContext.applyPageBackgroundStyles(view: view)
        
        // The Alignment wrapper centers the content vertically to shield
        // the views from being streched apart
        makeOrUpdateAlignmentWrapper(
            id: .containerView,
            horizontalAlignment: .center, verticalAlignment: .center,
            in: view, didMake: &didCreate
        ) { [self] containerView, didCreate in
            containerView.translatesAutoresizingMaskIntoConstraints = false
            makeOrUpdateContainer(
                id: .contentWrapper,
                in: containerView, didMake: &didCreate
            ) { [self] contentWrapper, didCreate in
                contentWrapper.translatesAutoresizingMaskIntoConstraints = false
                
                containerView.arrangedView = contentWrapper
                
                makeOrUpdateImageView(
                    id: .imageView, image: viewModel.image,
                    in: contentWrapper, didMake: &didCreate
                ) { imageView in
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                }
                makeOrUpdateHeading(
                    id: .headingLabel, text: viewModel.heading,
                    in: contentWrapper, didMake: &didCreate
                ) { label in
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.numberOfLines = 0
                    label.lineBreakMode = .byWordWrapping
                    label.textAlignment = .center
                }
                makeOrUpdateSubHeading(
                    id: .subHeadingLabel, text: viewModel.subHeading,
                    in: contentWrapper, didMake: &didCreate
                ) { label in
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.numberOfLines = 0
                    label.lineBreakMode = .byWordWrapping
                    label.textAlignment = .center
                }
            }
        }
        
        if didCreate {
            resetConstraints()
            view.setNeedsUpdateConstraints()
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activateParentConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        activateParentConstraints()
    }
    
    // MARK: - Layout
    
    @discardableResult
    private func activateParentConstraints() -> Bool {
        if let parent = parent, let parentView = parent.view, !parentConstraints.isEmpty {
            if view.hasSuperview(view: parentView, transitive: true) {
                NSLayoutConstraint.activate(parentConstraints)
                view.setNeedsLayout()
                return true
            }
        }
        return false
    }
    
    private var parentConstraints: [NSLayoutConstraint] = []
    
    override func willMove(toParent parent: UIViewController?) {
        parentConstraints.forEach { deinitializeConstraint($0) }
        parentConstraints.removeAll()
    }
    
    override func didMove(toParent parent: UIViewController?) {
        guard parentConstraints.isEmpty else { ContractError.guardAssertionFailed().fatal() }
        
        guard
            let pageVC = parent as? UIPageViewController,
            let parentView = pageVC.view,
            let view = view
        else {
            return
        }
        
        guard view.hasSuperview(view: parentView, transitive: true) else {
            // Neither the page view controller's nor the onboarding view controller's
            // views are part of view's hierarchy, so there is no way to use auto layout
            // to fix the view geometry to what onboarding VC wants, which is why we can't
            // disable auto-sizing for `view` as described elsewhere.
            //
            // Auto sizing however should work with local auto layout and it does
            // if using intrinsic content size, which we really don't want to do.
            //
            // Unless I made a silly mistake here, this is most annoying, because
            // UIPageViewController is aiming at exactly our use case and still we
            // will have to reimplement it.
            return
        }
        
        parentConstraints.append(contentsOf: [
            view.topAnchor.constraint(equalTo: parentView.topAnchor),
            view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate(parentConstraints)
    }
    
    override func createOrUpdateConstraints() {
        super.createOrUpdateConstraints()
        
        guard !hasControlledConstraints else { return }
        
        // Does not work (see comment in OnboardingVC.activateBindings()):
        // view.translatesAutoresizingMaskIntoConstraints = false
        
        // Fix image view size using image size
        if let imageView = controlledView(.imageView) as? UIImageView,
           let size = imageView.image?.size {
            addConstraintsForViewSize(.init(size), view: imageView)
        }
        
        // Let container fill super view
        guard let containerView = controlledView(.containerView) else {
            ContractError.guardAssertionFailed().fatal()
        }
        addConstraintsFillingSuperview(view: containerView)
        
        // Chain up content views vertically in their container and center horizontally
        let vspc = style.layout.verticalSpacing.vfl ?? "-"
        let vspct = style.layout.verticalTextSpacing.vfl ?? "-"
        addConstraints(
            withVisualFormat:
                "V:|-[\(ViewID.imageView)]\(vspc)[\(ViewID.headingLabel)]\(vspct)[\(ViewID.subHeadingLabel)]-|",
            options: .alignAllCenterX,
            metrics: nil, views: viewsForLayout, identifier: "vertical")
        
        // Center image view to define center of chain above
        if let imageView = controlledView(.imageView) {
            addConstraint(
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor), identifier: "centerX")
        }
        
        // Horizontal min padding for labels
        let ids: [ViewID] = [.headingLabel, .subHeadingLabel]
        for id in ids {
            addConstraintsForPadding(
                .init(horizontal: .greaterThanOrEqual(20)),
                view: controlledView(id)!)
        }
        
        // Apply size and padding settings in style.layout.views
        addConstraintsForViewsLayout()
    }
}
