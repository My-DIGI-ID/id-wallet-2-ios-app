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

extension UIImageView {
    /// Sets the image of self to the given identifier
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    ///
    /// - SeeAlso: `UIImage(named)`
    final func setImage(identifiedBy id: ImageNameIdentifier) {
        image = UIImage(identifiedBy: id)
    }
    
    /// Sets the image of self to the given identifier
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    /// - Parameters bundle: optional bundle where to look for the image-assets
    /// - Parameters traits: optional UITraitCollection
    ///
    /// - SeeAlso: `UIImage(named:in:compatibleWith:)`
    final func setImage(identifiedBy id: ImageNameIdentifier, in bundle: Bundle?, compatibleWith traits: UITraitCollection? = nil) {
        image = UIImage(identifiedBy: id, in: bundle, compatibleWith: traits)
    }
    
    /// Convenience Initializer to create UIImageView with an Image by ImageNameIdentifier
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    ///
    /// - SeeAlso: `UIImage(named)`
    convenience init(identifiedBy id: ImageNameIdentifier) {
        self.init(image: .init(identifiedBy: id))
    }
    
    /// Convenience Initializer to create UIImageView with an Image by ImageNameIdentifier
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    /// - Parameters bundle: optional bundle where to look for the image-assets
    /// - Parameters traits: optional UITraitCollection
    ///
    /// - SeeAlso: `UIImage(named:in:compatibleWith:)`
    convenience init(identifiedBy id: ImageNameIdentifier, in bundle: Bundle?, compatibleWith traits: UITraitCollection? = nil) {
        self.init(image: .init(identifiedBy: id, in: bundle, compatibleWith: traits))
    }
}
