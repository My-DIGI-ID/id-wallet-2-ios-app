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

public struct LayoutPriorities {
    let top: UILayoutPriority
    let bottom: UILayoutPriority
    let right: UILayoutPriority
    let left: UILayoutPriority
    
    public init (
        top: UILayoutPriority = .required,
        bottom: UILayoutPriority = .required,
        right: UILayoutPriority = .required,
        left: UILayoutPriority = .required) {
            self.top = top
            self.bottom = bottom
            self.left = left
            self.right = right
        }
}

extension UIView {
    
    /// Add all views as autolayout subviews
    /// - Parameter views: subviews to add
    func addAutolayoutSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
    
    /// Returns `Self` as an autolayout squared view
    /// - Parameter constant: Value of width and height of the view
    /// - Returns: An autolayout view with equal height and width
    func withEqualAutolayoutSize(constant: CGFloat) -> Self {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: constant),
            self.widthAnchor.constraint(equalToConstant: constant)])
        return self
    }
    
    /// Embeds (add + autolayout) a view in the superview and pins the layout anchors
    /// - Parameters:
    ///   - view: The view to embed
    ///   - insets: View layout spacing
    ///   - priorities: Defines the UILayoutPriority for top, bottom, left and right. Defaults to required for all dimensions
    public final func embed(_ view: UIView, insets: UIEdgeInsets = .zero, priorities: LayoutPriorities = .init()) {
        addSubview(view)
        [
            "H:|-(leftInset@\(priorities.left.rawValue))-[view]-(rightInset@\(priorities.right.rawValue))-|",
            "V:|-(topInset@\(priorities.top.rawValue))-[view]-(bottomInset@\(priorities.bottom.rawValue))-|"
        ]
            .constraints(
                with: [
                    "view": view
                ],
                metrics: [
                    "topInset": insets.top,
                    "leftInset": insets.left,
                    "bottomInset": insets.bottom,
                    "rightInset": insets.right
                ])
            .activate()
    }
}
