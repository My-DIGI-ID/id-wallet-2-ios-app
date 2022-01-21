//
//  PinEntryIntroVC.swift
//  IDWallet
//
//  Created by Michael Utech on 21.12.21.
//

import Foundation
import SwiftUI
import UIKit

extension PinEntrySuccessViewController {
  enum ViewID: String, BaseViewID {
    case containerView
    case headerContainer
    case titleLabel
    case titleSpacer
    case cancelButton

    case mainContentContainer
    case imageView
    case headingLabel
    case subHeadingLabel

    case footerContainer
    case commitButton

    var key: String { return rawValue }
  }

  struct Style: BaseViewControllerStyle {
    // swiftlint:disable nesting
    typealias LayoutType = Layout
    // swiftlint:enable nesting

    var themeContext: ThemeContext
    var layout: PinEntrySuccessViewController.Layout

    init(
      themeContext: ThemeContext = .main,
      layout: Layout = .regular
    ) {
      self.themeContext = themeContext
      self.layout = layout
    }

    init() { self.init(themeContext: .main, layout: .regular) }
  }

  struct Layout: BaseViewControllerLayout {
    // swiftlint:disable nesting
    typealias ViewIDType = ViewID
    // swiftlint:enable nesting

    static var regular: PinEntrySuccessViewController.Layout = .init()

    let headerMainSpacing: [LayoutPredicate] = .equal(360)
    let mainContentSpacing: CGFloat = 24
    let mainFooterSpacing: [LayoutPredicate] = .greaterThanOrEqual(20)

    let views: ViewsLayout<PinEntrySuccessViewController.ViewID> = [
      .containerView: .init(
        padding: .init(horizontal: 20, top: 60, bottom: 40)
      ),
      .headerContainer: .init(
        padding: .init(horizontal: 0, top: 0)
      ),
      .imageView: .init(
        padding: .init(top: 60)
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
    let title: String = NSLocalizedString("Richte deine Wallet ein", comment: "Page Title")
    let heading: String = NSLocalizedString("ID Wallet eingerichtet", comment: "Heading")
    let subHeading: String = NSLocalizedString(
      "Du hast deinen Zugangscode erfolgreich festgelegt. Bitte merke ihn dir gut - " +
      "du benötigst ihn bei jedem Öffnen der App.\n\nDu kannst jetzt weiter zum Wallet " +
      "und dort deine ersten Nachweise erstellen",
      comment: "Sub Heading")
    let commitTitle: String = NSLocalizedString(
      "Weiter zum Wallet", comment: "Commit Action Title")
  }

  class ViewModel {

    @Published var presentation: Presentation

    @Published var canCommit: Bool = true
    fileprivate let commit: (PinEntrySuccessViewController) -> Void

    @Published var canCancel: Bool = true
    fileprivate let cancel: (PinEntrySuccessViewController) -> Void

    init(
      commit: @escaping (PinEntrySuccessViewController) -> Void,
      cancel: @escaping (PinEntrySuccessViewController) -> Void,
      presentation: Presentation = .init()
    ) {
      self.commit = commit
      self.cancel = cancel
      self.presentation = presentation
    }
  }
}

class PinEntrySuccessViewController: BaseViewController<
  PinEntrySuccessViewController.ViewID, PinEntrySuccessViewController.Style,
  PinEntrySuccessViewController.ViewModel
> {

  // MARK: - Views

  // swiftlint:disable function_body_length
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

        makeOrUpdateSymbolButton(
          id: .cancelButton,
          systemName: "xmark",
          in: headerContainer, didMake: &didCreate
        ) { cancelButton in
          cancelButton.translatesAutoresizingMaskIntoConstraints = false
        }
      }

      makeOrUpdateImageView(
        id: .imageView,
        imageName: "ImagePinEntrySuccess",
        in: containerView, didMake: &didCreate
      ) { imageView in
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
          label.textAlignment = .center
        }

        makeOrUpdateSubHeading(
          id: .subHeadingLabel,
          text: viewModel.presentation.subHeading,
          in: mainContentContainer, didMake: &didCreate
        ) { label in
          label.translatesAutoresizingMaskIntoConstraints = false
          label.numberOfLines = 0
          label.lineBreakMode = .byWordWrapping
          label.textAlignment = .center
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

    if let imageView = controlledView(.imageView) as? UIImageView,
      let containerView = controlledView(.containerView) {
      addConstraint(
        imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -35),
        identifier: "image-centerX"
      )
    }
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
    if let viewModel = viewModel,
      viewModel.canCommit {
      viewModel.commit(self)
    }
  }

  @objc func cancelButtonTapped(sender: UIButton) {
    viewModel?.cancel(self)
  }
}
