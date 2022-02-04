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

struct ImageNameIdentifier: RawRepresentable {
    typealias RawValue = String
    let rawValue: RawValue
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension UIImage {
    /// re-implements UIImage.init(named:in:compatibleWith:) with a version that accepts the ImageNameIdentifier
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    /// - Parameters bundle: optional bundle where to look for the image-assets
    /// - Parameters traits: optional UITraitCollection
    ///
    /// - Returns: UIImage instance or nil
    /// - SeeAlso: `UIImage(named:in:compatibleWith:)`
    convenience init?(identifiedBy id: ImageNameIdentifier, in bundle: Bundle?, compatibleWith traits: UITraitCollection? = nil) {
        self.init(named: id.rawValue, in: bundle, compatibleWith: traits)
    }
    
    /// re-implements UIImage.init(named:) with a version that accepts the ImageNameIdentifier
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    /// - Returns: UIImage instance or nil
    /// - SeeAlso: `UIImage(named:)`
    convenience init?(identifiedBy id: ImageNameIdentifier) {
        self.init(named: id.rawValue)
    }
}
