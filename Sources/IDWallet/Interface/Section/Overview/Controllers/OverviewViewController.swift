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

private enum Constants {
    enum Text {}
    enum Layout {

        static let dividerHeight: CGFloat = 1
        static let divderBottomSpace: CGFloat = -33

        static let stackViewSpacing: CGFloat = 1
        static let scrollBarTopSpacing: CGFloat = 40

        static let contenStackViewInsets = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        static let buttonStackViewBottomDistance: CGFloat = -16
        static let buttonStackViewSpacing: CGFloat = 8
        static let headerSpacing: CGFloat = 48
        static let imageSpacing: CGFloat = -32
        static let leadingSpace: CGFloat = 16
        static let rowHeight: CGFloat = 54
        static let headerInsets = UIEdgeInsets(top: 24, left: Constants.Layout.leadingSpace, bottom: 24, right: Constants.Layout.leadingSpace)
        static let cornerRadius: CGFloat = 16
        static let headerStackViewBottomSpace: CGFloat = -16

        static let informationViewCornerRadius: CGFloat = 16
        static let informationViewLeading: CGFloat = 24
        static let informationViewHeight: CGFloat = 58

        static let imageSize = CGSize(width: 100, height: 25)

        static let rowColor = UIColor(hexString: "#E1E5F5")

        static let spacerHeight: CGFloat = 40
    }
}

class OverviewViewController: BareBaseViewController {

    let viewModel: OverviewViewModel
    var completion: () -> Void

    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: Images.regular.close,
            style: .plain,
            target: self,
            action: #selector(closeView))
        button.tintColor = .primaryBlue
        button.setTitleTextAttributes([
            .foregroundColor: UIColor.primaryBlue,
            .font: Typography.regular.bodyFont], for: .normal)
        button.setTitleTextAttributes([
            .foregroundColor: UIColor.primaryBlue,
            .font: Typography.regular.bodyFont], for: .highlighted)
        return button
    }()

    private lazy var navigationBar: UINavigationBar = {
        navigationItem.rightBarButtonItem = closeButton

        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.pushItem(navigationItem, animated: false)
        navigationBar.shadowImage = UIImage()
        return navigationBar
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView(frame: .zero)
        view.backgroundColor = .white
        view.addAutolayoutSubviews(contentView)
        return view
    }()

    private lazy var buttonsStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .equalSpacing
        return view
    }()

    private lazy var spacer = UIView()

    private lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            headerStackView,
            divider,
            headerView,
            spacer,
            buttonsStackView])
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = Constants.Layout.stackViewSpacing
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.addAutolayoutSubviews(stackView)
        return view
    }()

    // MARK: Header

    private lazy var headerLabel: UILabel = {
        let header = UILabel(frame: .zero)
        header.numberOfLines = 1
        return header
    }()

    private lazy var subHeaderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 1
        return label
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        return view
    }()

    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = .grey3
        return view
    }()

    private lazy var headerStackView: UIStackView = {
        let vertical = UIStackView(arrangedSubviews: [headerLabel, subHeaderLabel])
        vertical.axis = .vertical
        vertical.alignment = .leading

        let view = UIStackView(arrangedSubviews: [imageView, vertical])
        view.axis = .horizontal
        view.spacing = 8
        return view
    }()

    // MARK: Title

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var headerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.secondaryBlue
        view.layer.cornerRadius = Constants.Layout.cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.embed(titleLabel, insets: Constants.Layout.headerInsets)
        return view
    }()

    init(viewModel: OverviewViewModel, completion: @escaping () -> Void) {
        self.viewModel = viewModel
        self.completion = completion
        super.init(style: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        headerLabel.attributedText = viewModel.header
            .styledAs(.text(font: Typography.regular.boldBodyFont))
            .centered()

        subHeaderLabel.attributedText = viewModel.subHeader
            .styledAs(.text(font: Typography.regular.bodyFont))
            .centered()

        titleLabel.attributedText = viewModel.title
            .styledAs(.text(font: .plexSansBold(18)))

        if let imageURL = URL(string: viewModel.imageURL) {
            imageView.load(from: imageURL)
        }

        viewModel.buttons.forEach { (title: String, action: UIAction) in
            let button = WalletButton(titleText: title, primaryAction: action)
            if !buttonsStackView.arrangedSubviews.isEmpty {
                button.style = .secondary
            }
            buttonsStackView.addArrangedSubview(button)
        }

        for (index, row) in viewModel.rows.enumerated() {
            let view = createView(for: row, withRoundedBottomCorners: index == viewModel.rows.endIndex - 1)
            assert(stackView.subviews.count > 4)
            stackView.insertArrangedSubview(view, at: 3 + index)
            NSLayoutConstraint.activate([
                view.widthAnchor.constraint(equalTo: stackView.widthAnchor),
                view.heightAnchor.constraint(equalToConstant: Constants.Layout.rowHeight)])
        }
    }

    @objc
    private func closeView() {
        completion()
    }
}

// MARK: Layout

extension OverviewViewController {

    private func createView(for data: OverviewViewModel.DataRow, withRoundedBottomCorners: Bool) -> UIStackView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.attributedText = data.title.styledAs(.text(color: .grey1, font: .plexSans(12)))

        let valueLabel = UILabel(frame: .zero)
        valueLabel.attributedText = data.value.styledAs(.text(font: Typography.regular.bodyFont))

        let view = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        view.axis = .vertical
        view.spacing = 0
        view.distribution = .fillEqually
        view.backgroundColor = Constants.Layout.rowColor

        if withRoundedBottomCorners {
            view.layer.cornerRadius = Constants.Layout.cornerRadius
            view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.leadingSpace)])
        return view
    }

    private func setupLayout() {
        view.backgroundColor = .white

        view.addAutolayoutSubviews(navigationBar, scrollView)

        // Layout ScrollView
        scrollView.embed(contentView)
        contentView.embed(stackView, insets: Constants.Layout.contenStackViewInsets)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        // Layout Complete View
        [
            "V:|-[navBar]-(spacing)-[scrollView]-|",
            "H:|[navBar]|",
            "H:|[scrollView]|"]
            .constraints(
                with: ["navBar": navigationBar, "scrollView": scrollView],
                metrics: ["spacing": Constants.Layout.scrollBarTopSpacing])
            .activate()

        // Pin the button stackView to the bottom of the view
        let buttonStackViewPinToBottomConstraint = buttonsStackView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
        buttonStackViewPinToBottomConstraint.priority = .defaultLow
        buttonStackViewPinToBottomConstraint.constant = Constants.Layout.buttonStackViewBottomDistance
        buttonStackViewPinToBottomConstraint.isActive = true

        buttonsStackView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        buttonsStackView.spacing = Constants.Layout.buttonStackViewSpacing

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.Layout.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Constants.Layout.imageSize.height),
            headerStackView.bottomAnchor.constraint(equalTo: divider.topAnchor, constant: Constants.Layout.headerStackViewBottomSpace),
            headerStackView.heightAnchor.constraint(equalToConstant: Constants.Layout.headerSpacing),
            headerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            divider.heightAnchor.constraint(equalToConstant: Constants.Layout.dividerHeight),
            divider.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            divider.bottomAnchor.constraint(equalTo: headerView.topAnchor, constant: Constants.Layout.divderBottomSpace),
            spacer.heightAnchor.constraint(equalToConstant: Constants.Layout.spacerHeight)])
    }
}
