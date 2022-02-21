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
import Combine
import CocoaLumberjackSwift

// MARK: - Base View Controller
// MARK: -

/// Base ViewController providing the following features:
/// - all features of ``BareBaseViewController``
/// - defines a Style type streamlining parameterization of implementing view controllers
/// - automatically sets up status bar based on ThemeContext in `style`
/// - Provides support for ``ViewFactory``, ``LayoutFactory`` a nd ``BindingFactory``
/// - Provides stubs for integrating view creation, layout and bindinds into the controllers view life cycle
class BaseViewController<
    ViewIDType: BaseViewID, Style: BaseViewControllerStyle, ViewModel: AnyObject
>: BareBaseViewController {
    
    // MARK: - Storage
    
    var style: Style = Style() {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
            if [.willAppear, .didLayoutSubviews, .didAppear].contains(lifeCycleState) {
                let wasActive = areBindingsActive
                deactivateBindingsCounting()
                createOrUpdateViewsCounting()
                createOrUpdateConstraintsCounting()
                if wasActive {
                    activateBindingsCounting()
                }
            }
        }
    }
    
    private var wantToActivateBindings = false
    var viewModel: ViewModel! {
        willSet {
            if viewModel !== newValue && areBindingsActive {
                deactivateBindingsCounting()
                wantToActivateBindings = true
            }
        }
        didSet {
            if oldValue !== viewModel && wantToActivateBindings {
                activateBindingsCounting()
                wantToActivateBindings = false
            }
        }
    }
    
    private var controlledViews: [ViewIDType: UIView] = [:]
    private var controlledConstraints: Set<NSLayoutConstraint> = []
    private var controlledBindings: [Binding] = []
    
    private var createOrUpdateViewsCounter: UInt = 0
    private var resetViewsCounter: UInt = 0
    private var deactivateBindingsCounter = 0
    private var activateBindingsCounter = 0
    private var createOrUpdateConstraintsCounter: UInt = 0
    
    // MARK: - Default Behaviour Configuration
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return style.themeContext.colors.preferredStatusBarStyle
    }
    
    /// Indicates where there are any active controlled bindings. This is to be interpreted
    /// as all-or-nothing state.
    var areBindingsActive: Bool { !controlledBindings.isEmpty }
    
    // MARK: - View Factory Integration
    
    private func createOrUpdateViewsCounting() {
        let oldCount = createOrUpdateViewsCounter
        createOrUpdateViews()
        guard createOrUpdateViewsCounter > oldCount else {
            ContractError.guardAssertionFailed(
                "\(String(describing: type(of: self))).createOrUpdateViews() failed to call super"
            ).fatal()
        }
    }
    
    /// Implementations can override this method in order to create
    /// update or adopt views (f.e. from a storyboard). It will be called by BaseViewController
    /// at appropirate times (possibly more than once, f.e. when ``style`` changes).
    ///
    /// Implementations are required to call ``super.createOrUpdateViews()``
    /// at some point.
    ///
    /// Implementations are free to adopt the view management provided by BaseViewController
    /// and use the view factory tools or implement this individually.
    func createOrUpdateViews() {
        createOrUpdateViewsCounter += 1
    }
    
    private func resetViewsCounting() {
        let oldCount = resetViewsCounter
        resetViews()
        guard resetViewsCounter > oldCount else {
            ContractError.guardAssertionFailed(
                "\(String(describing: type(of: self))).resetViews() failed to call super"
            ).fatal()
        }
    }
    
    /// Deactives bindings, resets constraints, removes all controlled views from their
    /// super views and releases references to these views, effectively resetting the
    /// view controller to the state it had before ``viewWillAppear()`` was first
    /// called (not considering side effects that occurred independent of view/constraint/binding
    /// managment performed by BaseViewController).
    func resetViews() {
        deactivateBindingsCounting()
        resetConstraints()
        controlledViews.forEach { (id: ViewIDType, view: UIView) in
            view.removeFromSuperview()
            controlledViews[id] = nil
        }
    }
    
    // MARK: - Constraint Factory Integration
    
    private func createOrUpdateConstraintsCounting() {
        let oldCount = createOrUpdateConstraintsCounter
        createOrUpdateConstraints()
        guard createOrUpdateConstraintsCounter > oldCount else {
            ContractError.failedToCallSuper(self, feature: "createOrUpdateConstraints()").fatal()
        }
    }
    
    /// Implementations can override this method in order to create or update
    /// constraints. It will be called by BaseViewController at the appropriate time during
    /// the controllers life cycle and after ``createOrUpdateViews()`` has been called.
    ///
    /// Implementations are required to call ``super.createOrUpdateConstraints()``
    /// at some point.
    ///
    /// Implementations are free to adopt the constraint management provided by BaseViewController
    /// and or use the layout factory or just do their own.
    func createOrUpdateConstraints() {
        createOrUpdateConstraintsCounter += 1
    }
    
    /// Reverts the effects of ``createOrUpdateConstraints()`` and other methods
    /// that created or registered controlled constraints.
    final func resetConstraints() {
        controlledConstraints.forEach { deinitializeConstraint($0) }
        controlledConstraints.removeAll()
    }
    
    /// Deactivates the constraint and releases references to views as well as removing it
    /// from previously referenced views.
    final func deinitializeConstraint(_ constraint: NSLayoutConstraint) {
        constraint.isActive = false
        if let first = constraint.firstItem {
            first.removeConstraint(constraint)
        }
        if let second = constraint.secondItem {
            second.removeConstraint(constraint)
        }
    }
    
    // MARK: - Binding Factory Integration
    
    private func activateBindingsCounting() {
        let oldCount = activateBindingsCounter
        activateBindings()
        guard activateBindingsCounter > oldCount else {
            ContractError.failedToCallSuper(self, feature: "activateBindings()").fatal()
        }
    }
    
    /// Implementation can override this method in order to create or activate
    /// bindings. It will be called at appropriate times, maybe multiple times
    /// using the mechanism provided by ``BindingFactory``
    ///
    /// Implementations should check ``areBindingsActive`` and do nothing if `true`.
    @objc
    func activateBindings() {
        activateBindingsCounter += 1
    }
    
    private func deactivateBindingsCounting() {
        let oldCount = deactivateBindingsCounter
        deactivateBindings()
        guard deactivateBindingsCounter > oldCount else {
            ContractError.failedToCallSuper(self, feature: "deactivateBindings()").fatal()
        }
    }
    
    /// Deactivates all previously registered controlled bindings.
    func deactivateBindings() {
        deactivateBindingsCounter += 1
        
        controlledBindings.forEach { binding in
            deactivateBinding(binding: binding)
        }
        controlledBindings.removeAll()
    }
    
    private func deactivateBinding(binding: Binding) {
        switch binding {
        case .cancellable(let subscription):
            subscription.cancel()
        case .control(let control, let target, let selector, let event):
            control.removeTarget(target, action: selector, for: event)
        case .custom(let deactive):
            deactive()
        }
    }
    
    // MARK: - Initialization
    
    init(style: Style, viewModel: ViewModel) {
        super.init()
        self.style = style
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Life Cycle
    
    /// This implementation deactivates bindings, creates or update views, update constraints and then activates bindings
    /// in this order to integrate the functionality provided by ``renderingDelegate``
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        deactivateBindingsCounting()
        createOrUpdateViewsCounting()
        createOrUpdateConstraintsCounting()
        activateBindingsCounting()
    }
    
    /// This implementation calls the ``renderingDelegate``s ``updateContstraints`` method here.
    override func updateViewConstraints() {
        DDLogVerbose("\(String(describing: type(of: self))).updateViewConstraints() started")
        
        createOrUpdateConstraintsCounting()
        super.updateViewConstraints()
        
        DDLogVerbose("\(String(describing: type(of: self))).updateViewConstraints() finished")
    }
    
    /// This implementation deactivates bindings here.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deactivateBindingsCounting()
    }
}

// MARK: - ViewFactory implementation

extension BaseViewController: ViewFactory, ThemeContextDependent {
    
    var themeContext: ThemeContext { style.themeContext }
    
    func controlledView(_ id: ViewIDType) -> UIView? {
        return controlledViews[id]
    }
    
    private func addView(_ view: UIView, asArrangedOrSubviewTo parent: UIView?) {
        if let parent = parent as? UIStackView {
            parent.addArrangedSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
        } else {
            parent?.addSubview(view)
        }
    }
    
    /// Registers the `view` with the specified ID sets the view's ``accessibilityIdentifier`` to
    /// `id.key` and adds the view as an arranged or subview to `parent`.
    ///
    /// This can be used to adopt views created in storyboards, sub-viewcontrollers or by other means.
    ///
    /// **Note:** ``resetViews`` does not distinguish between created and adopted views (the default
    ///      implementation will remove a view from its ``superview`` and ``controlledViews``).
    ///
    /// **Note:** If a different view is already registered for the ID, a fatal error will be raised.
    ///
    /// - Parameter id: The view's ID used to locate it in `controlledViews` and to set the view's
    ///      ``accessibilityIdentifier``
    /// - Parameter view: The view to add to controlled views.
    @discardableResult
    func addControlledView<T: UIView>(_ id: ViewIDType, view: T, in parent: UIView?) -> T {
        if let existing = controlledViews[id] {
            guard existing !== view else {
                ContractError.guardAssertionFailed(
                    "Attempt to register view [\(view)] as [\(id)] failed because " +
                    "another view [\(existing)] is already registered for this ID"
                ).fatal()
            }
        }
        
        if let parent = parent {
            let existing = view.superview
            guard existing == nil || existing === parent else {
                ContractError.guardAssertionFailed(
                    "The view registered as [\(id)] is expected to be a subview " +
                    "of [\(parent)], but is a subview of [\(existing!)]"
                ).fatal()
            }
            if existing === nil {
                addView(view, asArrangedOrSubviewTo: parent)
            }
        }
        
        view.accessibilityIdentifier = id.key
        controlledViews[id] = view
        
        return view
    }
    
    @discardableResult
    func removeControlledView<T: UIView>(_ id: ViewIDType, ofType viewType: T.Type, from parent: UIView?) -> T? {
        if let view = controlledView(id, ofType: T.self) {
            controlledViews[id] = nil
            return view
        }
        return nil
    }
}

// MARK: - LayoutFactory implementation

extension BaseViewController: LayoutFactory {
    var hasControlledConstraints: Bool { !controlledConstraints.isEmpty }
    
    var viewsForLayout: [String: UIView] {
        controlledViews.reduce(into: [String: UIView]()) { result, item in
            result[item.key.key] = item.value
        }
    }
    
    @discardableResult
    func addControlledConstraints(
        _ constraints: [NSLayoutConstraint],
        identifier: String,
        activate: Bool
    ) -> [NSLayoutConstraint] {
        controlledConstraints.formUnion(constraints)
        if activate {
            NSLayoutConstraint.activate(constraints)
        }
        for constraint in constraints {
            constraint.identifier = identifier
        }
        return constraints
    }
    
    @discardableResult
    func addConstraintsForViewsLayout(
        identifier: String? = nil
    ) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        for item in style.layout.views {
            guard let viewID = item.key as? ViewIDType else { ContractError.guardAssertionFailed().fatal() }
            let layout = item.value
            guard let view = controlledView(viewID) else {
                ContractError.guardAssertionFailed(
                    "Failed to apply view layout for ID \(viewID): The view has not been created"
                ).fatal()
            }
            constraints.append(
                contentsOf: addConstraintsForViewLayout(
                    layout,
                    view: view,
                    identifier: identifier ?? "viewsLayout"))
        }
        return constraints
    }
}

// MARK: - BindingFactory implementation

extension BaseViewController: BindingFactory {
    func addControlledBinding(_ binding: Binding) {
        controlledBindings.append(binding)
    }
}
