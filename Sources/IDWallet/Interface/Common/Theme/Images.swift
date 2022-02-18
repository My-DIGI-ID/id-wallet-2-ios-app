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

/// Provides access to images defined in Assets. The interface is designed to allow a theme context
/// to provide alternative versions without having to change the client code, so far we don't need that yet.
struct Images {
    static let regular = Images()
    var onboardingActivePageIndicator: UIImage {
        UIImage.requiredImage(name: "ImagePageIndicatorActive")
    }
    
    var onboardingInactivePageIndicator: UIImage {
        UIImage.requiredImage(name: "ImagePageIndicatorInactive")
    }
    var onboardingPage1: UIImage {
        UIImage.requiredImage(name: "ImageOnboardingPage1")
    }
    
    var onboardingPage2: UIImage {
        UIImage.requiredImage(name: "ImageOnboardingPage2")
    }
    
    var onboardingPage3: UIImage {
        UIImage.requiredImage(name: "ImageOnboardingPage3")
    }
    
    var pinEntrySuccess: UIImage {
        UIImage.requiredImage(name: "ImagePinEntrySuccess")
    }
    
    var infoBoxExclamationIcon: UIImage {
        UIImage.requiredImage(name: "ImageIconExclamation")
    }
    
    var iconArrowUp: UIImage {
        UIImage.requiredImage(name: "ImageIconArrowUp")
    }
    
    var iconFail: UIImage {
        UIImage.requiredImage(name: "fail")
    }
    
    var close: UIImage {
        UIImage.requiredImage(name: "close")
    }
    
    var externalLinkIcon: UIImage {
        UIImage.requiredImage(name: "externalLink")
    }
}
