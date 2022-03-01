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
                arrangedViewConstraints?.activate()
                
                setNeedsLayout()
            }
        }
    }

    private var arrangedViewConstraints: [NSLayoutConstraint]?
    
    private lazy var topGuide: UILayoutGuide = {
        let result = UILayoutGuide()

        result.identifier = "topGuide"
        addLayoutGuide(result)
        result.topAnchor.constraint(equalTo: topAnchor).isActive = true

        return result
    }()
    private lazy var trailingGuide: UILayoutGuide = {
        let result = UILayoutGuide()

        result.identifier = "trailingGuide"
        addLayoutGuide(result)
        result.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        return result
    }()
    private lazy var bottomGuide: UILayoutGuide = {
        let result = UILayoutGuide()

        result.identifier = "bottomGuide"
        addLayoutGuide(result)
        result.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        return result
    }()
    private lazy var leadingGuide: UILayoutGuide = {
        let result = UILayoutGuide()

        result.identifier = "leadingGuide"
        addLayoutGuide(result)
        result.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true

        return result
    }()

    private var guideConstraints: [NSLayoutConstraint]!
    
    var verticalAlignment: VerticalAlignment = .center {
        didSet {
            updateVerticalAlignmentConstraints()
        }
    }

    private var verticalAlignmentConstraints = [VerticalAlignment: [NSLayoutConstraint]]()
    
    var horizontalAlignment: HorizontalAlignment = .center {
        didSet {
            updateHorizontalAlignmentConstraints()
        }
    }

    private var horizontalAlignmentConstraints = [HorizontalAlignment: [NSLayoutConstraint]]()
        
    // MARK: - Layout Guides
    private func setupOnce() {
        setupVerticalAlignmentConstraints()
        setupHorizontalAlignmentConstraints()
    }

    // MARK: - Vertical Alignment
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
                verticalAlignmentConstraints[key]?.activate()
            } else {
                verticalAlignmentConstraints[key]?.deactivate()
            }
        }
    }
    
    // MARK: - Horizontal Alignment
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
                horizontalAlignmentConstraints[key]?.activate()
            } else {
                horizontalAlignmentConstraints[key]?.deactivate()
            }
        }
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
}
