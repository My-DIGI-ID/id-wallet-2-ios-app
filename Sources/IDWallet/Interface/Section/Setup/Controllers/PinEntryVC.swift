//
//  PinEntryViewController.swift
//  IDWallet
//
//  Created by Michael Utech on 01.12.21.
//

import Combine
import UIKit

// MARK: - Configuration

extension PinEntryViewController {

  enum ViewID: String, BaseViewID {
    case containerView
    case titleContainer
    case titleLabel
    case titleSpacer
    case cancelButton
    case headingLabel
    case subHeadingLabel
    case pinCodeView
    case numberPad
    case commitButton

    var key: String { rawValue }
  }

  struct Style: BaseViewControllerStyle {
    static let regular = Style()
    let themeContext: ThemeContext
    let layout: Layout
    let pinCodeViewStyle: PinCodeView.Style
    let numberPadStyle: NumberPad.Style

    init() {
      self.init(themeContext: ThemeContext.main)
    }

    init(
      themeContext: ThemeContext,
      layout: Layout? = nil,
      pinCodeViewStyle: PinCodeView.Style = .regular,
      numberPadStyle: NumberPad.Style = .regular
    ) {
      self.themeContext = themeContext
      self.layout = layout ?? defaultOrCompressed(.regular, .compressed)
      self.pinCodeViewStyle = pinCodeViewStyle
      self.numberPadStyle = numberPadStyle
    }
  }

  struct Layout: BaseViewControllerLayout {
    static let regular = Layout(
      views: [
        .containerView: .init(
          padding: Padding(20, top: 60, bottom: 40)),
        .headingLabel: .init(
          // wrap text evenly across lines:
          padding: Padding(
            horizontal: [.greaterThanOrEqual(1000, 50)]
          )),
        .titleSpacer: .init(
          // Force title and button to the sides:
          size: .init(width: .equal(1000, 50), height: .equal(0)))
      ],
      labelVerticalSpacing: 20.0,
      verticalSpacing: 50.0
    )

    static let compressed = Layout(
      views: [
        .containerView: .init(
          padding: Padding(20, top: 30, bottom: 20)),
        .headingLabel: .init(
          // wrap text evenly across lines:
          padding: Padding(
            horizontal: [.equal(1000, 50)]
          )),
        .subHeadingLabel: .init(
          // wrap text evenly across lines:
          padding: Padding(
            horizontal: [.equal(1000, 50)]
          )),
        .titleSpacer: .init(
          // Force title and button to the sides:
          size: .init(width: .equal(1000, 50), height: .equal(0)))
      ],
      labelVerticalSpacing: 0.0,
      verticalSpacing: 20.0
    )

    let views: ViewsLayout<ViewID>
    let labelVerticalSpacing: CGFloat
    let verticalSpacing: CGFloat
  }
}

// MARK: -
// MARK: - PinEntryViewController

class PinEntryViewController: BaseViewController<
    PinEntryViewController.ViewID,
    PinEntryViewController.Style,
    PinEntryViewModel>,
  NumberPadDelegate {

  // MARK: - Views

  // swiftlint:disable function_body_length
  override func createOrUpdateViews() {
    super.createOrUpdateViews()

    var didCreate = false

    style.themeContext.applyPageBackgroundStyles(view: view)

    makeOrUpdateVStack(
      id: .containerView,
      alignment: .center, distribution: .equalCentering, spacing: style.layout.verticalSpacing,
      removeExistingArrangedViews: false,
      in: view, didMake: &didCreate
    ) { vstack, didCreate in
      vstack.translatesAutoresizingMaskIntoConstraints = false

      self.makeOrUpdateHStack(
        id: .titleContainer,
        alignment: .firstBaseline,
        distribution: .fill,
        removeExistingArrangedViews: false,
        in: vstack, didMake: &didCreate
      ) { hstack, didCreate in
        hstack.translatesAutoresizingMaskIntoConstraints = false

        self.makeOrUpdateTitle(
          id: .titleLabel,
          text: self.viewModel.presentation.title,
          in: hstack, didMake: &didCreate
        ) { label in
          label.translatesAutoresizingMaskIntoConstraints = false
          label.textAlignment = .left
        }

        self.makeOrUpdateView(
          id: .titleSpacer,
          in: hstack, didMake: &didCreate
        ) { spacer in
          spacer.translatesAutoresizingMaskIntoConstraints = false
          spacer.backgroundColor = .red
        }

        self.makeOrUpdateSymbolButton(
          id: .cancelButton,
          systemName: "xmark",
          in: hstack, didMake: &didCreate
        ) { cancelButton in
          cancelButton.translatesAutoresizingMaskIntoConstraints = false
        }
      }

      self.makeOrUpdateHeading(
        id: .headingLabel,
        text: self.viewModel.presentation.heading,
        in: vstack, didMake: &didCreate
      ) { label in
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.makeOrUpdateHeightConstraint(
          height: self.style.themeContext.typography.headingFont.lineHeight * 2,
          relation: .greaterThanOrEqual,
          priority: .init(251))
      }

      self.makeOrUpdateSubHeading(
        id: .subHeadingLabel,
        text: self.viewModel.presentation.subHeading,
        in: vstack, didMake: &didCreate
      ) { label in
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center

        label.makeOrUpdateHeightConstraint(
          height: self.style.themeContext.typography.subHeadingFont.lineHeight * 3,
          relation: .greaterThanOrEqual,
          priority: .init(251))
      }

      self.makeOrUpdatePinCodeView(
        id: .pinCodeView, pin: self.viewModel.pin,
        in: vstack, didMake: &didCreate
      ) { pinCodeView in
        pinCodeView.translatesAutoresizingMaskIntoConstraints = false
      }

      self.makeOrUpdateNumberPad(
        id: .numberPad,
        in: vstack, didMake: &didCreate
      ) { view in
        view.translatesAutoresizingMaskIntoConstraints = false
        vstack.setCustomSpacing(0, after: view)
      }

      self.makeOrUpdatePrimaryActionButton(
        id: .commitButton,
        title: self.viewModel.presentation.commitActionTitle,
        in: vstack, didMake: &didCreate
      ) { button in
        button.translatesAutoresizingMaskIntoConstraints = false
      }
    }

    // Trigger layout if views have been created

    if didCreate {
      resetConstraints()
      view.setNeedsUpdateConstraints()
    }
  }

  // MARK: - Layout

  override func createOrUpdateConstraints() {
    super.createOrUpdateConstraints()
    guard !hasControlledConstraints else { return }

    addConstraintsForViewsLayout()
  }

  // MARK: - Bindings

  // swiftlint:disable function_body_length
  override func activateBindings() {
    super.activateBindings()

    guard
      !areBindingsActive,
      let viewModel = viewModel,
      let numberPad = controlledView(.numberPad) as? NumberPad,
      let commitButton = controlledView(.commitButton) as? UIButton,
      let cancelButton = controlledView(.cancelButton) as? UIButton,
      let titleLabel = controlledView(.titleLabel) as? UILabel,
      let headingLabel = controlledView(.headingLabel) as? UILabel,
      let subHeadingLabel = controlledView(.subHeadingLabel) as? UILabel,
      let pinCodeView = controlledView(.pinCodeView) as? PinCodeView
    else {
      return
    }

    bind(
      activate: { numberPad.delegate = self },
      deactivate: { [weak numberPad] in numberPad?.delegate = nil }
    )

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
        commitButton.setTitle(presentation.commitActionTitle, for: .normal)
      },
      viewModel.$canAdd.sink { value in
        UIView.animate(withDuration: animationDuration) {
          numberPad.canAddDigit = value
        }
      },
      viewModel.$canRemove.sink { value in
        UIView.animate(withDuration: animationDuration) {
          numberPad.canRemoveLastDigit = value
        }
      },
      viewModel.$canCommit.sink { value in
          if viewModel.autoCommit {
              commitButton.isHidden = true
          }
        UIView.animate(withDuration: animationDuration) {
          commitButton.isEnabled = value
          viewModel.presentation.themeContext.applyPrimaryActionButtonStyles(
            button: commitButton)
        }
      },
      viewModel.$pin.sink { value in
        UIView.animate(withDuration: animationDuration) {
          pinCodeView.pin = value
        }
      }
    ])
  }
  // swiftlint:enable function_body_length

  func numberPadDidRemoveLastDigit(_ numberPad: NumberPad) {
    if let viewModel = viewModel, viewModel.canRemove {
      viewModel.remove()
    }
  }

  func numberPad(_ numberPad: NumberPad, didAddDigit digit: String) {
    if let viewModel = viewModel, viewModel.canAdd && viewModel.isValidPinCharacter(digit) {
        viewModel.add(digit, viewController: self)
    }
  }

  @objc func commitButtonTapped(sender: UIButton) {
      if let viewModel = self.viewModel,
         self.viewModel.canCommit {
          self.viewModel.commit(self)
      }
  }

  @objc func cancelButtonTapped(sender: UIButton) {
    viewModel?.cancel(self)
  }
}



