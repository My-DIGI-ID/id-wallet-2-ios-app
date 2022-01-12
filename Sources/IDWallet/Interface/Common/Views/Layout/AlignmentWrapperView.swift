//
//  AlignmentView.swift
//  IDWallet
//
//  Created by Michael Utech on 20.12.21.
//

import CocoaLumberjackSwift
import Foundation
import UIKit

class AlignmentWrapperView: UIView {

  // MARK: - Local Types

  enum VerticalAlignment {
    case top
    case center
    case fill
    case bottom
  }
  enum HorizontalAlignment {
    case leading
    case center
    case fill
    case trailing
  }

  // MARK: - Initialization
  init(
    _ arrangedView: UIView? = nil,
    horizontalAlignment: HorizontalAlignment = .fill,
    verticalAlignment: VerticalAlignment = .center
  ) {
    super.init(frame: CGRect.zero)
    setupOnce()
    self.horizontalAlignment = horizontalAlignment
    self.verticalAlignment = verticalAlignment
    self.arrangedView = arrangedView
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupOnce()
  }
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupOnce()
  }

  // MARK: - Setup

  private func setupOnce() {
    setupLayoutGuides()
    setupVerticalAlignmentConstraints()
    setupHorizontalAlignmentConstraints()
  }

  // MARK: - Arranged View

  var arrangedView: UIView? {
    willSet {
      guard newValue !== arrangedView else { return }

      if let constraints = arrangedViewConstraints {
        NSLayoutConstraint.deactivate(constraints)
        arrangedView?.removeConstraints(constraints)
        removeConstraints(constraints)
        arrangedViewConstraints = nil
      }

      if let arrangedView = arrangedView {
        assert(arrangedView.superview === self)

        arrangedView.removeFromSuperview()
      }
    }
    didSet {
      guard oldValue !== arrangedView else { return }

      assert(arrangedViewConstraints == nil)

      if let arrangedView = arrangedView {
        if !subviews.contains(arrangedView) {
          addSubview(arrangedView)
        }
        arrangedViewConstraints = [
          arrangedView.topAnchor.constraint(equalTo: topGuide.bottomAnchor),
          arrangedView.trailingAnchor.constraint(equalTo: trailingGuide.leadingAnchor),
          arrangedView.bottomAnchor.constraint(equalTo: bottomGuide.topAnchor),
          arrangedView.leadingAnchor.constraint(equalTo: leadingGuide.trailingAnchor)
        ]
        arrangedViewConstraints![0].identifier = "arrangedView-top"
        arrangedViewConstraints![1].identifier = "arrangedView-trailing"
        arrangedViewConstraints![2].identifier = "arrangedView-bottom"
        arrangedViewConstraints![3].identifier = "arrangedView-leading"
        NSLayoutConstraint.activate(arrangedViewConstraints!)

        addConstraints(arrangedViewConstraints!)

        setNeedsLayout()
      }
    }
  }
  private var arrangedViewConstraints: [NSLayoutConstraint]?

  // MARK: - Layout Guides

  private var topGuide: UILayoutGuide!
  private var trailingGuide: UILayoutGuide!
  private var bottomGuide: UILayoutGuide!
  private var leadingGuide: UILayoutGuide!
  private var guideConstraints: [NSLayoutConstraint]!
  private func setupLayoutGuides() {
    topGuide = UILayoutGuide()
    topGuide.identifier = "topGuide"
    addLayoutGuide(topGuide)

    trailingGuide = UILayoutGuide()
    trailingGuide.identifier = "trailingGuide"
    addLayoutGuide(trailingGuide)

    bottomGuide = UILayoutGuide()
    bottomGuide.identifier = "bottomGuide"
    addLayoutGuide(bottomGuide)

    leadingGuide = UILayoutGuide()
    leadingGuide.identifier = "leadingGuide"
    addLayoutGuide(leadingGuide)

    guideConstraints = [
      topGuide.topAnchor.constraint(equalTo: topAnchor),
      trailingGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
      bottomGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
      leadingGuide.leadingAnchor.constraint(equalTo: leadingAnchor)
    ]
    NSLayoutConstraint.activate(guideConstraints)
  }

  // MARK: - Vertical Alignment

  var verticalAlignment: VerticalAlignment = .center {
    didSet {
      updateVerticalAlignmentConstraints()
    }
  }
  private var verticalAlignmentConstraints = [VerticalAlignment: [NSLayoutConstraint]]()
  private func setupVerticalAlignmentConstraints() {
    verticalAlignmentConstraints = [
      .top: [
        topGuide.heightAnchor.constraint(equalToConstant: 0),
        bottomGuide.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
      ],
      .center: [
        topGuide.heightAnchor.constraint(equalTo: bottomGuide.heightAnchor)
      ],
      .fill: [
        topGuide.heightAnchor.constraint(equalToConstant: 0),
        bottomGuide.heightAnchor.constraint(equalToConstant: 0)
      ],
      .bottom: [
        topGuide.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
        bottomGuide.heightAnchor.constraint(equalToConstant: 0)
      ]
    ]
    updateHorizontalAlignmentConstraints()
  }
  private func updateVerticalAlignmentConstraints() {
    for key in verticalAlignmentConstraints.keys {
      if key == verticalAlignment {
        NSLayoutConstraint.activate(verticalAlignmentConstraints[key]!)
      } else {
        NSLayoutConstraint.deactivate(verticalAlignmentConstraints[key]!)
      }
    }
  }

  // MARK: - Horizontal Alignment

  var horizontalAlignment: HorizontalAlignment = .center {
    didSet {
      updateHorizontalAlignmentConstraints()
    }
  }
  private var horizontalAlignmentConstraints = [HorizontalAlignment: [NSLayoutConstraint]]()
  private func setupHorizontalAlignmentConstraints() {
    horizontalAlignmentConstraints = [
      .leading: [
        leadingGuide.widthAnchor.constraint(equalToConstant: 0),
        trailingGuide.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
      ],
      .center: [
        leadingGuide.widthAnchor.constraint(equalTo: trailingGuide.widthAnchor)
      ],
      .fill: [
        leadingGuide.widthAnchor.constraint(equalToConstant: 0),
        trailingGuide.widthAnchor.constraint(equalToConstant: 0)
      ],
      .trailing: [
        leadingGuide.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),
        trailingGuide.widthAnchor.constraint(equalToConstant: 0)
      ]
    ]
    updateHorizontalAlignmentConstraints()
  }
  private func updateHorizontalAlignmentConstraints() {
    for key in horizontalAlignmentConstraints.keys {
      if key == horizontalAlignment {
        NSLayoutConstraint.activate(horizontalAlignmentConstraints[key]!)
      } else {
        NSLayoutConstraint.deactivate(horizontalAlignmentConstraints[key]!)
      }
    }
  }
}
