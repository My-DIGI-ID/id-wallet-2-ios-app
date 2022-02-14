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
import AVFoundation

private enum Constants {
    
    enum Text {
        static let title = "qr_code_title".localized
        static let hint = "qr_code_hint".localized
    }
    
    enum NavigationBar {
        static let titleFont = Typography.regular.headingFont
    }
    
    enum Layout {
        static let cameraSize: CGFloat = 300
        static let navBarTopSpacing: CGFloat = 40
        static let navBarToCameraSpacing: CGFloat = 42
        static let cameraToHintSpacing: CGFloat = 48
        static let cornerRadius: CGFloat = 20
        
        enum Bracket {
            static let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            static let lineLength: CGFloat = 30
            static let lineWidth: CGFloat = 4
            static let cornerRadius: CGFloat = 20
        }
    }
    
    enum Color {
        static let divder = UIColor(hexString: "#D9D9D9")
    }
}

enum QRScannerResult {
    case success(value: String)
    case failure(error: ScanError)
    case cancelled
}

class QRScannerViewController: BareBaseViewController {
    
    var completion: (QRScannerResult) -> Void
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: Images.regular.close, style: .plain, target: self, action: #selector(closeView))
        button.tintColor = .primaryBlue
        button.setTitleTextAttributes([
            .foregroundColor: UIColor.primaryBlue,
            .font: Typography.regular.bodyFont], for: .normal)
        button.setTitleTextAttributes([
            .foregroundColor: UIColor.primaryBlue,
            .font: Typography.regular.bodyFont], for: .highlighted)
        return button
    }()
    
    private lazy var brackeView: BracketView = {
        let view = BracketView(
            lineLength: Constants.Layout.Bracket.lineLength,
            lineWidth: Constants.Layout.Bracket.lineWidth,
            cornerRadius: Constants.Layout.Bracket.cornerRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationItem = UINavigationItem(title: Constants.Text.title)
        navigationItem.rightBarButtonItem = closeButton
        
        let navigationBar = UINavigationBar(frame: .zero)
        navigationBar.barTintColor = .white
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.walBlack,
            .font: Constants.NavigationBar.titleFont]
        
        navigationBar.shadowImage = UIImage()
        navigationBar.pushItem(navigationItem, animated: false)
        
        return navigationBar
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.attributedText = NSAttributedString(
            string: Constants.Text.hint,
            attributes: [
                .foregroundColor: UIColor.grey1,
                .font: Typography.regular.subHeadingFont])
        return label
    }()
    
    private lazy var scannerContentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.Layout.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    let captureSession = AVCaptureSession()
    
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        layer.connection?.videoOrientation = .portrait
        layer.videoGravity = .resizeAspectFill
        return layer
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    init(completion: @escaping (QRScannerResult) -> Void) {
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
        
#if targetEnvironment(simulator)
#else
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
        completion(.failure(error: .acesss))
        return
    }
    
    let videoInput: AVCaptureDeviceInput
    
    do {
        videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
    } catch {
        completion(.failure(error: .failure))
        return
    }
    
    if captureSession.canAddInput(videoInput) {
        captureSession.addInput(videoInput)
    } else {
        completion(.failure(error: .acesss))
        return
    }
    
    let metadataOutput = AVCaptureMetadataOutput()
    
    if captureSession.canAddOutput(metadataOutput) {
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.qr]
    } else {
        completion(.failure(error: .failure))
        return
    }
    
    if !captureSession.isRunning {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
#endif
    }
    
    @objc
    private func closeView() {
        completion(.cancelled)
    }
}

// MARK: Layout

extension QRScannerViewController {
    private func setupLayout() {
        
        view.backgroundColor = .white
        view.addAutolayoutSubviews(navigationBar, scannerContentView, hintLabel)
        
        scannerContentView.layer.insertSublayer(previewLayer, below: brackeView.layer)
        scannerContentView.embed(brackeView, insets: Constants.Layout.Bracket.insets)
        [
            "V:|-(s1)-[navBar]-(s2)-[camera(camSize)]-(s3)-[hint]",
            "H:|[navBar]|",
            "H:|-[hint]-|",
            "H:|-(>=0)-[camera(camSize)]-(>=0)-|"
        ].constraints(
            with: [
                "navBar": navigationBar,
                "camera": scannerContentView,
                "hint": hintLabel],
            metrics: [
                "s1": Constants.Layout.navBarTopSpacing,
                "s2": Constants.Layout.navBarToCameraSpacing,
                "s3": Constants.Layout.cameraToHintSpacing,
                "camSize": Constants.Layout.cameraSize])
            .activate()
        NSLayoutConstraint.activate([scannerContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
    }
    
    override func viewDidLayoutSubviews() {
        previewLayer.frame = scannerContentView.layer.bounds
    }
}

// MARK: Scanner Delegate

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let value = readableObject.stringValue else { return }
            dismiss(animated: true) {
                self.completion(.success(value: value))
            }
        } else {
            captureSession.startRunning()
        }
    }
}
