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

extension UIView {
    ///
    /// Locates the views first sublayer that is a CAGradientLayer
    ///
    /// - Returns: an existing layer `CAGradientLayer` or nil if none is found.
    ///
    func gradientLayer() -> CAGradientLayer? {
        return(self.layer.sublayers?.compactMap { $0 as? CAGradientLayer })?.first
    }
    ///
    /// Removes the layer returned by `gradientLayer()`, if one is found
    /// - Returns: the removed layer or `nil`
    ///
    @discardableResult
    func removeGradientLayer(view: UIView) -> CAGradientLayer? {
        if let gradientLayer = gradientLayer() {
            gradientLayer.removeFromSuperlayer()
            return gradientLayer
        }
        return nil
    }
    ///
    /// Locates an existing `CAGradientLayer` or creates a new one and applies the specified  `action` to it.
    ///
    /// This is used to set up or update a gradient layer, operating under the assumption that there is only one
    /// gradient layer.
    ///
    /// A newly created gradient layer will be added as sublayer after action was applied to it.
    ///
    /// - Parameter action: a closure operating on the gradient layer
    ///
    /// - Returns:The gradient layer, a newly created layer will have a `CAGradientLayer.superlayer` of nil.
    ///
    @discardableResult
    func withGradientLayer(_ action: (_ gradientLayer: CAGradientLayer) -> Void) -> CAGradientLayer {
        if let gradientLayer = self.gradientLayer() {
            action(gradientLayer)
            return gradientLayer
        }
        let gradientLayer = CAGradientLayer()
        action(gradientLayer)
        self.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }
    
    @discardableResult
    func makeOrUpdateHeightConstraint(
        height: CGFloat,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority? = nil,
        then: ((_ height: NSLayoutConstraint) -> Void)? = nil
    ) -> NSLayoutConstraint {
        let proto = NSLayoutConstraint(
            item: self, attribute: .height, relatedBy: relation, toItem: nil, attribute: .width,
            multiplier: 0, constant: height
        )
        if let priority = priority, priority != proto.priority {
            proto.priority = priority
        }
        
        let constraint = heightConstraint { heightConstraint in
            if
                let existing = heightConstraint,
                existing.isActive,
                proto.relation == existing.relation,
                proto.priority == existing.priority {
                if proto.constant == existing.constant && proto.multiplier == existing.multiplier {
                    // existing constraint matches spec
                    return existing
                }
                return proto
            }
            return nil
        }
        
        let result = constraint ?? proto
        result.isActive = true
        addConstraint(result)
        
        then?(result)
        
        return result
    }
    
    @discardableResult
    func makeOrUpdateWidthConstraint(
        width: CGFloat,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority? = nil,
        then: ((_ width: NSLayoutConstraint) -> Void)? = nil
    ) -> NSLayoutConstraint {
        let proto = NSLayoutConstraint(
            item: self, attribute: .width, relatedBy: relation, toItem: nil, attribute: .width,
            multiplier: 0, constant: width
        )
        if let priority = priority, priority != proto.priority {
            proto.priority = priority
        }
        
        let newConstraint = widthConstraint { widthConstraint in
            if
                let existing = widthConstraint,
                existing.isActive,
                proto.relation == existing.relation,
                proto.priority == existing.priority {
                if proto.constant == existing.constant && proto.multiplier == existing.multiplier {
                    // existing constraint matches spec
                    return existing
                }
                return proto
            }
            return nil
        }
        
        let result = newConstraint ?? proto
        result.isActive = true
        addConstraint(result)
        
        then?(result)
        
        return result
    }
    
    @discardableResult
    func makeFillSuperviewConstraints() -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-[view]-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil,
                views: ["view": self]))
        constraints.append(
            contentsOf: NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-[view]-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil,
                views: ["view": self]))
        NSLayoutConstraint.activate(constraints)
        return constraints
    }
    
    @discardableResult
    func makeOrUpdateSizeConstraints(
        size: CGSize,
        relation: NSLayoutConstraint.Relation = .equal,
        priority: UILayoutPriority? = nil,
        then: ((_ width: NSLayoutConstraint, _ height: NSLayoutConstraint) -> Void)? = nil
    ) -> [NSLayoutConstraint] {
        let result = [
            makeOrUpdateWidthConstraint(width: size.width),
            makeOrUpdateHeightConstraint(height: size.height)
        ]
        then?(result[0], result[1])
        return result
    }
    
    @discardableResult
    func heightConstraint(
        relation: NSLayoutConstraint.Relation = .equal,
        then: ((_: NSLayoutConstraint?) -> NSLayoutConstraint?)? = nil
    ) -> NSLayoutConstraint? {
        let result = constraints.first(where: { constraint in
            constraint.firstItem === self && constraint.relation == relation
            && constraint.firstAttribute == .height && constraint.secondItem == nil
        })
        let override = then?(result)
        if override != nil && override !== result {
            if let result = result {
                removeConstraint(result)
            }
            addConstraint(override!)
        }
        return result
    }
    
    @discardableResult
    func widthConstraint(
        relation: NSLayoutConstraint.Relation = .equal,
        then: ((_: NSLayoutConstraint?) -> NSLayoutConstraint?)? = nil
    ) -> NSLayoutConstraint? {
        let result = constraints.first(where: { constraint in
            constraint.firstItem === self && constraint.relation == relation
            && constraint.firstAttribute == .width && constraint.secondItem == nil
        })
        let override = then?(result)
        if override != nil && override !== result {
            if let result = result {
                removeConstraint(result)
            }
            addConstraint(override!)
        }
        return result
    }
    
    func hasSuperview(view: UIView, transitive: Bool = false) -> Bool {
        if view == superview {
            return true
        }
        
        if transitive, let superview = superview {
            return superview.hasSuperview(view: view, transitive: transitive)
        }
        
        return false
    }
}
