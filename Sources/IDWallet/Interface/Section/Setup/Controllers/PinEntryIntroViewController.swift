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

extension PinEntryIntroViewController {
    enum ViewID: String, BaseViewID {
        case containerView
        case headerContainer
        case titleLabel
        case titleSpacer
        case cancelButton
        
        case mainContentContainer
        case headingLabel
        case subHeadingLabel
        case infoBox
        case infoBoxIcon
        case infoBoxTextWrapper
        case infoBoxTippLabel
        case infoBoxTextLabel
        
        case footerContainer
        case commitButton
        
        var key: String { return rawValue }
    }
    
    struct Style: BaseViewControllerStyle {
        // swiftlint:disable nesting
        typealias LayoutType = Layout
        // swiftlint:enable nesting
        
        var themeContext: ThemeContext
        var layout: PinEntryIntroViewController.Layout
        
        init(
            themeContext: ThemeContext = .alternative,
            layout: Layout = .regular
        ) {
            self.themeContext = themeContext
            self.layout = layout
        }
        
        init() { self.init(themeContext: .alternative, layout: .regular) }
    }
    
    struct Layout: BaseViewControllerLayout {
        // swiftlint:disable nesting
        typealias ViewIDType = ViewID
        // swiftlint:enable nesting
        
        static var regular: PinEntryIntroViewController.Layout = .init()
        
        let headerMainSpacing: [LayoutPredicate] = .equal(50)
        let mainContentSpacing: CGFloat = 24
        let mainFooterSpacing: [LayoutPredicate] = .greaterThanOrEqual(20)
        
        let views: ViewsLayout<PinEntryIntroViewController.ViewID> = [
            .containerView: .init(
                padding: .init(horizontal: 20, top: 60, bottom: 40)
            ),
            .headerContainer: .init(
                padding: .init(horizontal: 0, top: 0)
            ),
            .mainContentContainer: .init(
                padding: .init(horizontal: 0)
            ),
            .footerContainer: .init(
                padding: .init(horizontal: 0, bottom: 0)
            )
        ]
        
        init() {}
    }
    
    struct Presentation {
        let title: String = NSLocalizedString("Richte Deine Wallet ein", comment: "Page Title")
        let heading: String = NSLocalizedString("ID Wallet aktivieren", comment: "Heading")
        let subHeading: String = NSLocalizedString(
            "Lege einen Zugangscode fest, um Deine ID Wallet zu aktivieren. " +
            "Den Zugangscode brauchst Du bei jeder Benutzung der ID Wallet App.",
            comment: "Sub Heading")
        let tipTitle: String = NSLocalizedString("Hinweis:", comment: "Tip Title")
        let tipText: String = NSLocalizedString(
            "Der Zugangscode ist nur auf Deinem Smartphone gespeichert. " +
            "Wenn Du Ihn verlierst kann er nicht zurückgesetzt werden",
            comment: "Tip Text")
        let commitTitle: String = NSLocalizedString("Jetzt festlegen", comment: "Commit Action Title")
    }
    
    class ViewModel {
        @Published var presentation: Presentation
        
        @Published var canCommit: Bool = true
        fileprivate let commit: (PinEntryIntroViewController) -> Void
        
        @Published var canCancel: Bool = true
        fileprivate let cancel: (PinEntryIntroViewController) -> Void
        
        init(
            commit: @escaping (PinEntryIntroViewController) -> Void,
            cancel: @escaping (PinEntryIntroViewController) -> Void,
            presentation: Presentation = Presentation()
        ) {
            self.commit = commit
            self.cancel = cancel
            self.presentation = presentation
        }
    }
}

class PinEntryIntroViewController: BaseViewController<
PinEntryIntroViewController.ViewID, PinEntryIntroViewController.Style,
PinEntryIntroViewController.ViewModel
> {
    // MARK: - Views
    override func createOrUpdateViews() {
        super.createOrUpdateViews()
        
        var didCreate: Bool = false
        
        style.themeContext.applyPageBackgroundStyles(view: view)
        
        makeOrUpdateContainer(
            id: .containerView,
            in: view, didMake: &didCreate
        ) { [self] containerView, didCreate in
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            makeOrUpdateHStack(
                id: .headerContainer,
                alignment: .firstBaseline,
                distribution: .fill,
                removeExistingArrangedViews: false,
                in: containerView, didMake: &didCreate
            ) { [self] headerContainer, didCreate in
                headerContainer.translatesAutoresizingMaskIntoConstraints = false
                
                makeOrUpdateTitle(
                    id: .titleLabel,
                    text: viewModel.presentation.title,
                    in: headerContainer, didMake: &didCreate
                ) { label in
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.textAlignment = .left
                }
                
                makeOrUpdateView(
                    id: .titleSpacer,
                    in: headerContainer, didMake: &didCreate
                ) { spacer in
                    spacer.translatesAutoresizingMaskIntoConstraints = false
                }
                
                makeOrUpdateCloseButton(
                    id: .cancelButton,
                    in: headerContainer, didMake: &didCreate
                ) { cancelButton in
                    cancelButton.translatesAutoresizingMaskIntoConstraints = false
                }
            }
            makeOrUpdateVStack(
                id: .mainContentContainer,
                spacing: style.layout.mainContentSpacing,
                in: containerView, didMake: &didCreate
            ) { mainContentContainer, didCreate in
                mainContentContainer.translatesAutoresizingMaskIntoConstraints = false
                
                mainContentContainer.alignment = .center
                
                makeOrUpdateHeading(
                    id: .headingLabel,
                    text: viewModel.presentation.heading,
                    in: mainContentContainer, didMake: &didCreate
                ) { label in
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.numberOfLines = 0
                    label.lineBreakMode = .byWordWrapping
                    label.textAlignment = .left
                }
                
                makeOrUpdateSubHeading(
                    id: .subHeadingLabel,
                    text: viewModel.presentation.subHeading,
                    in: mainContentContainer, didMake: &didCreate
                ) { label in
                    label.translatesAutoresizingMaskIntoConstraints = false
                    label.numberOfLines = 0
                    label.lineBreakMode = .byWordWrapping
                    label.textAlignment = .left
                }
                
                makeOrUpdateHStack(
                    id: .infoBox,
                    spacing: style.layout.mainContentSpacing,
                    in: mainContentContainer, didMake: &didCreate
                ) { infoBox, didCreate in
                    infoBox.translatesAutoresizingMaskIntoConstraints = false
                    
                    infoBox.alignment = .center
                    infoBox.layer.cornerRadius = 15
                    infoBox.backgroundColor = .init(hexString: "F0F2FB")
                    infoBox.isLayoutMarginsRelativeArrangement = true
                    infoBox.directionalLayoutMargins = NSDirectionalEdgeInsets(
                        top: 20, leading: 20, bottom: 20, trailing: 20)
                    
                    makeOrUpdateImageView(
                        id: .infoBoxIcon,
                        imageName: "ImageIconExclamation",
                        in: infoBox, didMake: &didCreate
                    ) { infoBoxIcon in
                        infoBoxIcon.translatesAutoresizingMaskIntoConstraints = false
                    }
                    
                    makeOrUpdateVStack(
                        id: .infoBoxTextWrapper,
                        in: infoBox, didMake: &didCreate
                    ) { [self] infoBoxTextWrapper, didCreate in
                        infoBoxTextWrapper.translatesAutoresizingMaskIntoConstraints = false
                        
                        makeOrUpdateTipTitle(
                            id: .infoBoxTippLabel,
                            text: viewModel.presentation.tipTitle,
                            in: infoBoxTextWrapper, didMake: &didCreate
                        ) { infoBoxTippLabel in
                            infoBoxTippLabel.translatesAutoresizingMaskIntoConstraints = false
                        }
                        
                        makeOrUpdateBody(
                            id: .infoBoxTextLabel,
                            text: viewModel.presentation.tipText,
                            in: infoBoxTextWrapper, didMake: &didCreate
                        ) { infoBoxTextLabel in
                            infoBoxTextLabel.translatesAutoresizingMaskIntoConstraints = false
                            infoBoxTextLabel.numberOfLines = 0
                            infoBoxTextLabel.lineBreakMode = .byWordWrapping
                        }
                    }
                }
            }
            
            makeOrUpdateAlignmentWrapper(
                id: .footerContainer,
                horizontalAlignment: .center, verticalAlignment: .bottom,
                in: containerView, didMake: &didCreate
            ) { [self] footerContainer, didCreate in
                footerContainer.translatesAutoresizingMaskIntoConstraints = false
                
                makeOrUpdatePrimaryActionButton(
                    id: .commitButton, title: viewModel.presentation.commitTitle,
                    isEnabled: viewModel.canCommit,
                    in: footerContainer, didMake: &didCreate
                ) { commitButton in
                    commitButton.translatesAutoresizingMaskIntoConstraints = false
                    footerContainer.arrangedView = commitButton
                }
            }
        }
    }
    // swiftlint:enable function_body_length
    
    override func createOrUpdateConstraints() {
        super.createOrUpdateConstraints()
        
        guard !hasControlledConstraints else { return }
        
        addConstraintsForViewsLayout(
            identifier: "style.layout.views")
        
        let spc1 = style.layout.headerMainSpacing.vfl ?? "-"
        let spc2 = style.layout.mainFooterSpacing.vfl ?? "-"
        addConstraints(
            withVisualFormat:
                "V:[\(ViewID.headerContainer)]\(spc1)[\(ViewID.mainContentContainer)]\(spc2)[\(ViewID.footerContainer)]",
            views: viewsForLayout,
            identifier: "vertical")
    }
    
    override func activateBindings() {
        super.activateBindings()
        
        guard
            !areBindingsActive,
            let viewModel = viewModel,
            let commitButton = controlledView(.commitButton) as? UIButton,
            let cancelButton = controlledView(.cancelButton) as? UIButton,
            let titleLabel = controlledView(.titleLabel) as? UILabel,
            let headingLabel = controlledView(.headingLabel) as? UILabel,
            let subHeadingLabel = controlledView(.subHeadingLabel) as? UILabel
        else {
            return
        }
        
        bind(
            control: commitButton, target: self, action: #selector(commitButtonTapped(sender:)),
            for: .touchUpInside)
        bind(
            control: cancelButton, target: self, action: #selector(cancelButtonTapped(sender:)),
            for: .touchUpInside)
        
        let animationDuration = 0.25
        bind(subscriptions: [
            viewModel.$presentation.sink { presentation in
                titleLabel.text = presentation.title
                headingLabel.text = presentation.heading
                subHeadingLabel.text = presentation.subHeading
                commitButton.setTitle(presentation.commitTitle, for: .normal)
            },
            viewModel.$canCommit.sink { [weak self] value in
                UIView.animate(withDuration: animationDuration) {
                    commitButton.isEnabled = value
                    self?.style.themeContext.applyPrimaryActionButtonStyles(
                        button: commitButton)
                }
            }
        ])
    }
    
    @objc func commitButtonTapped(sender: UIButton) {
        if
            let viewModel = viewModel, viewModel.canCommit {
            viewModel.commit(self)
        }
    }
    
    @objc func cancelButtonTapped(sender: UIButton) {
        viewModel?.cancel(self)
    }
}
