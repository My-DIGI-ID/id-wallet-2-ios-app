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

fileprivate extension ImageNameIdentifier {
    static let deleteBack = ImageNameIdentifier(rawValue: "DeleteLeft")
}

private enum Constants {
    enum Style {
        static let color = UIColor.white
    }

    enum Layout {
        static let horizontalPadding = 0.0
        static let verticalPadding = 0.0
        static let horizontalSpacing = 16.0
        static let verticalSpacing = 0.0

        static var metrics: [String: Any] {
            return [
                "hPadding": Constants.Layout.horizontalPadding as Any,
                "vPadding": Constants.Layout.verticalPadding as Any,
                "hSpacing": Constants.Layout.horizontalSpacing as Any,
                "vSpacing": Constants.Layout.verticalSpacing as Any
            ]
        }
    }

    static let letters: [String: String] = [
        "2": "ABC",
        "3": "DEF",
        "4": "GHI",
        "5": "JKL",
        "6": "MNO",
        "7": "PQRS",
        "8": "TUV",
        "9": "WXYZ"
    ]
}

@objc protocol NumberPadDelegate {
    @objc
    optional func numberPad(_ numberPad: NumberPad, didAddDigit: String)
    
    @objc
    optional func numberPadDidRemoveLastDigit(_ numberPad: NumberPad)
}

class NumberPad: UIView {
    weak var delegate: NumberPadDelegate?

    private lazy var contentView: UIStackView = {
        let result = UIStackView()

        result.translatesAutoresizingMaskIntoConstraints = false

        result.axis = .vertical

        return result
    }()

    private var keyViewsByName: [String: UIControl] = [:]

    // State
    var canAddDigit: Bool = false {
        didSet {
            for number in 0...9 {
                if let control = keyViewsByName["k\(number)"] {
                    control.isEnabled = canAddDigit
                }
            }
        }
    }
    
    var canRemoveLastDigit: Bool = false {
        didSet {
            keyViewsByName["deleteKey"]?.isEnabled = canRemoveLastDigit
        }
    }

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        var size = CGSize.zero
        var sizedViews: [UIView] = []
        var spacerViews: [UIView] = []

        addSubview(contentView)
        [ "V:|-[contentView]-|", "H:|-[contentView]-|"]
            .constraints(with: ["contentView": contentView])
            .activate()

        var rows = [UIStackView]()

        for rowIndex in 0...2 {
            let rowStack = hstack()
            rows.append(rowStack)

            rowStack.addArrangedSubview(spacer())
            for number in 1...3 {
                rowStack.addArrangedSubview(makeNumberPadKey(number: number + rowIndex * 3))
            }
            rowStack.addArrangedSubview(spacer())
            contentView.addArrangedSubview(rowStack)
        }
        let lastRow = hstack()
        rows.append(lastRow)
        lastRow.addArrangedSubview(spacer())
        lastRow.addArrangedSubview(placeholer())
        lastRow.addArrangedSubview(makeNumberPadKey(number: 0))
        lastRow.addArrangedSubview(deleteKey())
        lastRow.addArrangedSubview(spacer())
        contentView.addArrangedSubview(lastRow)

        sizedViews.forEach {
            $0.makeOrUpdateSizeConstraints(
                size: size, priority: .required)
        }
        spacerViews.forEach {
            $0.makeOrUpdateSizeConstraints(
                size: CGSize(width: 0, height: size.height), priority: .required)
        }

        func maxSz(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
            return CGSize(width: max(lhs.width, rhs.width), height: max(lhs.height, rhs.height))
        }
        func makeNumberPadKey(number: Int) -> NumberPadKey {
            let viewName = "k\(number)"
            let key = "\(number)"
            let secondary = Constants.letters[key]
            let result = NumberPadKey(key, withSecondaryKeys: secondary ?? "")
            keyViewsByName[viewName] = result
            size = maxSz(size, maxSz(result.frame.size, result.intrinsicContentSize))
            sizedViews.append(result)
            result.addTarget(self, action: #selector(didTapNumberKey(sender:)), for: .touchUpInside)
            result.translatesAutoresizingMaskIntoConstraints = false
            return result
        }
        func deleteKey() -> UIView {
            let result = UIButton.systemButton(
                with: UIImage(existing: .deleteBack)
                    .withRenderingMode(.alwaysTemplate),
                target: self,
                action: #selector(didTapDeleteKey(sender:))
            )
            result.tintColor = Constants.Style.color

            result.accessibilityIdentifier = "Key_Delete"
            keyViewsByName["deleteKey"] = result

            size = maxSz(size, maxSz(result.frame.size, result.intrinsicContentSize))
            result.frame.size = size
            result.translatesAutoresizingMaskIntoConstraints = false
            let view = UIView()
            view.addSubview(result)
            view.frame.size = size
            sizedViews.append(view)
            result.makeFillSuperviewConstraints()
            return view
        }
        func placeholer() -> UIView {
            let result = UIView()
            sizedViews.append(result)
            result.translatesAutoresizingMaskIntoConstraints = false
            return result
        }
        func spacer() -> UIView {
            let result = UIView()
            spacerViews.append(result)
            result.translatesAutoresizingMaskIntoConstraints = false
            return result
        }
        func hstack() -> UIStackView {
            let result = UIStackView()
            result.translatesAutoresizingMaskIntoConstraints = false
            result.axis = .horizontal
            result.alignment = .firstBaseline
            result.spacing = Constants.Layout.horizontalSpacing
            return result
        }
        func vstack() -> UIStackView {
            let result = UIStackView()
            result.translatesAutoresizingMaskIntoConstraints = false
            result.axis = .vertical
            result.alignment = .center
            result.spacing = Constants.Layout.verticalSpacing
            return result
        }
    }
}

// MARK: - Actions

extension NumberPad {
    @objc
    func didTapDeleteKey(sender: UIButton) {
        delegate?.numberPadDidRemoveLastDigit?(self)
    }
    
    @objc
    func didTapNumberKey(sender: NumberPadKey) {
        delegate?.numberPad?(self, didAddDigit: sender.primaryKey)
    }
}

// MARK: - Layout

extension NumberPad {
    /// This view will not work using autoresizing
    override final class var requiresConstraintBasedLayout: Bool { return true }
    
    /// Uses the (primary) key label for baseline alignment
    override var forFirstBaselineLayout: UIView { return keyViewsByName["4"] ?? self }
    
    /// Uses the (primary) key label for baseline alignment
    override var forLastBaselineLayout: UIView { return keyViewsByName["6"] ?? self }
}
