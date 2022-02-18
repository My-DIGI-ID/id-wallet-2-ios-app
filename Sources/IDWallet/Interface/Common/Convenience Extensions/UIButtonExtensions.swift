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

enum ButtonImagePlacement: Equatable {
    case leading
    case trailing
}

extension UIButton {
    var imagePlacement: ButtonImagePlacement {
        get {
            let direction = UIApplication.shared.userInterfaceLayoutDirection
            switch self.semanticContentAttribute {
            case .forceRightToLeft:
                return direction == .rightToLeft ? .leading : .trailing
            case .forceLeftToRight:
                return direction == .leftToRight ? .leading : .trailing
            case .unspecified, .playback, .spatial:
                return .leading
            @unknown default:
                return .leading
            }
        }
        set {
            switch newValue {
            case .leading:
                self.semanticContentAttribute = .unspecified
            case .trailing:
                switch UIApplication.shared.userInterfaceLayoutDirection {
                case .rightToLeft:
                    self.semanticContentAttribute = .forceLeftToRight
                case .leftToRight:
                    self.semanticContentAttribute = .forceRightToLeft
                @unknown default:
                    self.semanticContentAttribute = .forceRightToLeft
                }
            }
        }
    }
    
    func setButtonImagePadding(_ padding: CGFloat) {
        // Elaborate way to silence the one deprecation warning we have so far
        // The alternative to discriminate and use a different implementations for
        // iOS 15 (Configuration) was not worth the risk and the two mechanisms
        // don't mix well (.updated(for:) would be ok if it was static)
        var deprecated: ImageEdgeInsetsDeprecated = self
        deprecated.imageEdgeInsets =
        UIEdgeInsets(top: 0, left: padding, bottom: 0, right: 0)
    }
}

private protocol ImageEdgeInsetsDeprecated {
    var imageEdgeInsets: UIEdgeInsets { get set }
}

extension UIButton: ImageEdgeInsetsDeprecated {}
