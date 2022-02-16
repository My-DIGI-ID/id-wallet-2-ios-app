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

@MainActor
@objc protocol CustomTabBarDelegate: AnyObject {
    @objc
    optional func customTabBar(_ bar: CustomTabBar, didSelect item: UITabBarItem)
}

@MainActor
class CustomTabBar: UIView {
    
    // MARK: - Configuration
    
    weak var delegate: CustomTabBarDelegate?
    
    var items: [UITabBarItem] = [] {
        didSet {
            buttons = items.map { CustomBarButton(barItem: $0) }
            selectedIndex = min(items.count - 1, max(0, selectedIndex))
        }
    }
    
    private(set) var buttons: [CustomBarButton] = [] {
        willSet {
            reset()
        }
        didSet {
            setNeedsLayout()
        }
    }
    
    var selectedIndex: Int = -1 {
        didSet {
            for index in 0..<buttons.count {
                let button = buttons[index]
                button.isSelected = index == selectedIndex
            }
            if let delegate = delegate, let item = selectedItem {
                delegate.customTabBar?(self, didSelect: item)
            }
        }
    }
    
    var selectedItem: UITabBarItem? {
        get {
            guard selectedIndex >= 0, selectedIndex < items.count else { return nil }
            
            return items[selectedIndex]
        }
        set(value) {
            let index = value == nil ? nil : items.firstIndex(of: value!)
            if let index = index {
                selectedIndex = index
            } else {
                selectedIndex = -1
            }
        }
    }
    
    // MARK: - Setup
    
    private var controlledConstraints: [NSLayoutConstraint] = []
    private var controlledGuides: [UILayoutGuide] = []
    private var separator: UIView = UIView()
    
    private(set) var heightConstraint: NSLayoutConstraint?
    private(set) var bottomPaddingConstraint: NSLayoutConstraint?
    
    var bottomPadding: CGFloat = 0.0 {
        didSet {
            if let bottomPaddingConstraint = bottomPaddingConstraint {
                bottomPaddingConstraint.constant = bottomPadding
            } else {
                setNeedsLayout()
            }
        }
    }
    
    var height: CGFloat = 100.0 {
        didSet {
            if let heightConstraint = heightConstraint {
                heightConstraint.constant = height
            } else {
                setNeedsLayout()
            }
        }
    }
    
    override func layoutSubviews() {
        if controlledConstraints.isEmpty {
            setup()
        }
    }
    
    @objc
    func buttonTap(sender: CustomBarButton) {
        guard let index = buttons.firstIndex(of: sender) else {
            return
        }
        selectedIndex = index
    }
    
    private func reset() {
        for constraint in controlledConstraints {
            constraint.isActive = false
            if let first = constraint.firstItem {
                first.removeConstraint(constraint)
            }
            if let second = constraint.secondItem {
                second.removeConstraint(constraint)
            }
        }
        controlledConstraints.removeAll()
        
        controlledGuides.forEach { removeLayoutGuide($0) }
        controlledGuides.removeAll()
        
        buttons.forEach {
            $0.removeTarget(self, action: #selector(buttonTap(sender:)), for: .touchUpInside)
            $0.removeFromSuperview()
        }
        separator.removeFromSuperview()
        
        bottomPaddingConstraint = nil
        heightConstraint = nil
    }
    
    private func setupSeparator() {
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        controlledConstraints.append(contentsOf: [
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])
        separator.backgroundColor = .grey6
    }
    
    private func setup() {
        setupSeparator()
        
        var leading = UILayoutGuide()
        let bottom = UILayoutGuide()
        var spacers: [UILayoutGuide] = [leading, bottom]
        var trailing = leading
        
        bottomPaddingConstraint = bottom.heightAnchor.constraint(equalToConstant: bottomPadding)
        controlledConstraints.append(contentsOf: [
            self.heightAnchor.constraint(equalToConstant: height),
            leading.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottom.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomPaddingConstraint!
        ])
        
        let width = buttons.map { $0.intrinsicContentSize.width }.max()!
        for button in buttons {
            button.addTarget(self, action: #selector(buttonTap(sender:)), for: .touchUpInside)
            
            trailing = UILayoutGuide()
            spacers.append(trailing)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(button)
            
            controlledConstraints.append(contentsOf: [
                button.widthAnchor.constraint(equalToConstant: width),
                trailing.widthAnchor.constraint(equalTo: leading.widthAnchor),
                leading.trailingAnchor.constraint(equalTo: button.leadingAnchor),
                button.bottomAnchor.constraint(equalTo: bottom.topAnchor),
                button.trailingAnchor.constraint(equalTo: trailing.leadingAnchor)
            ])
            
            let top = NSLayoutConstraint(
                item: button, attribute: .top,
                relatedBy: .greaterThanOrEqual,
                toItem: self, attribute: .top,
                multiplier: 1, constant: 0)
            top.priority = .init(1)
            controlledConstraints.append(top)
            
            leading = trailing
        }
        
        spacers.forEach { addLayoutGuide($0) }
        controlledGuides = spacers
        
        controlledConstraints.append(
            trailing.trailingAnchor.constraint(equalTo: trailingAnchor))
        NSLayoutConstraint.activate(controlledConstraints)
    }
    
    // MARK: - Initialization
    
    init(
        tabBarItems: [UITabBarItem]
    ) {
        super.init(frame: CGRect.zero)
        
        // swiftlint:disable inert_defer
        // (defer is used to trigger didSet)
        defer {
            items = tabBarItems
        }
        // swiftlint:enable inert_defer
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
