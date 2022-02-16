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
import WebKit

private enum Constants {

    enum NavigationBar {
        static let titleFont = Typography.regular.titleFont
    }

    enum Layout {
        static let dividerHeight: CGFloat = 1
    }

    enum Color {
        static let divder: UIColor = .grey5
    }
}

class WebViewController: BareBaseViewController {

    private lazy var doneButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeView))
        button.tintColor = .primaryBlue
        button.setTitleTextAttributes([.foregroundColor: UIColor.primaryBlue,
                                       .font: Typography.regular.bodyFont], for: .normal)
        button.setTitleTextAttributes([.foregroundColor: UIColor.primaryBlue,
                                       .font: Typography.regular.bodyFont], for: .highlighted)
        return button
    }()

    private lazy var navigationBar: UINavigationBar = {
        let navigationItem = UINavigationItem(title: viewModel.title)
        navigationItem.rightBarButtonItem = doneButton

        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.walBlack,
                                             .font: Constants.NavigationBar.titleFont]

        navigationBar.shadowImage = Constants.Color.divder.image()

        navigationBar.pushItem(navigationItem, animated: false)

        return navigationBar
    }()

    private lazy var webview: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: configuration)
        return view
    }()

    private let viewModel: WebViewViewModelProtocol

    init(viewModel: WebViewViewModelProtocol) {
        self.viewModel = viewModel
        super.init(style: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        let request = URLRequest(url: viewModel.url)
        webview.load(request)
    }

    @objc
    private func closeView() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Layout

extension WebViewController {
    private func setupLayout() {
        view.addAutolayoutSubviews(navigationBar, webview)
        [
            "V:|-[navBar]-(spacing)-[webView]-|",
            "H:|[navBar]|",
            "H:|[webView]|",
        ]
            .constraints(with: [
                "navBar": navigationBar,
                "webView": webview
            ],
                         metrics: [
                            "spacing": Constants.Layout.dividerHeight
            ])
            .activate()
    }
}
