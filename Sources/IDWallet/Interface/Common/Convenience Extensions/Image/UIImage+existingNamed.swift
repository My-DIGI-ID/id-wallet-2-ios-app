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

extension UIImage {
    /// re-implements UIImage.init(named:in:compatibleWith:) with a version that accepts the ImageNameIdentifier, but must return a non-nill result.
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    /// - Parameters bundle: optional bundle where to look for the image-assets
    /// - Parameters traits: optional UITraitCollection
    ///
    /// - Returns: UIImage instance
    /// - SeeAlso: `UIImage(named:in:compatibleWith:)`
    convenience init(existing id: ImageNameIdentifier, in bundle: Bundle?, compatibleWith traits: UITraitCollection? = nil) {
        assert(UIImage(identifiedBy: id, in: bundle, compatibleWith: traits) != nil, "Expected image with name \(id.rawValue) but found nil instead")
        
        // Note [@mHader]: assertion ensures that image exists when in debug mode. Hence the force-unwrap is safe here
        self.init(identifiedBy: id, in: bundle, compatibleWith: traits)!
    }
    
    /// re-implements UIImage.init(named:) with a version that accepts the ImageNameIdentifier, but must return a non-nill result
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    /// - Returns: UIImage instance
    /// - SeeAlso: `UIImage(named:)`
    convenience init(existing id: ImageNameIdentifier) {
        assert(UIImage(identifiedBy: id) != nil, "Expected image with name \(id.rawValue) but found nil instead")
        
        // Note [@mHader]: assertion ensures that image exists when in debug mode. Hence the force-unwrap is safe here
        self.init(identifiedBy: id)!
    }
    
    /// re-implements UIImage.init(systemName:compatibleWith:) with a version that accepts the ImageNameIdentifier, but must return a non-nill result.
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    /// - Parameters traits: optional UITraitCollection
    ///
    /// - Returns: UIImage instance
    /// - SeeAlso: `UIImage(named:in:compatibleWith:)`
    convenience init(existingSystemId id: ImageNameIdentifier, compatibleWith traits: UITraitCollection? = nil) {
        assert(UIImage(systemId: id, compatibleWith: traits) != nil, "Expected system-image with name \(id.rawValue) but found nil instead")
        
        // Note [@mHader]: assertion ensures that image exists when in debug mode. Hence the force-unwrap is safe here
        self.init(systemId: id, compatibleWith: traits)!
    }
    
    /// re-implements UIImage.init(systemName:) with a version that accepts the ImageNameIdentifier, but must return a non-nill result
    ///
    /// - Parameters id: The identifier for the image that should be loaded
    /// - Returns: UIImage instance
    /// - SeeAlso: `UIImage(named:)`
    convenience init(existingSystemId id: ImageNameIdentifier) {
        assert(UIImage(systemId: id) != nil, "Expected system-image with name \(id.rawValue) but found nil instead")
        
        // Note [@mHader]: assertion ensures that image exists when in debug mode. Hence the force-unwrap is safe here
        self.init(systemId: id)!
    }
}
