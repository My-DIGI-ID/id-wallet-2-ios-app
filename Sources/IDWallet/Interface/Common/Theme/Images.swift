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
    static let onboardingActivePageIndicator = ImageNameIdentifier(rawValue: "PageIndicatorActive")
    static let onboardingInactivePageIndicator = ImageNameIdentifier(rawValue: "PageIndicatorInactive")
    static let onboardingPage1 = ImageNameIdentifier(rawValue: "Onboarding1")
    static let onboardingPage2 = ImageNameIdentifier(rawValue: "Onboarding2")
    static let onboardingPage3 = ImageNameIdentifier(rawValue: "Onboarding3")
    
    static let pinEntrySuccess = ImageNameIdentifier(rawValue: "PinEntrySuccess")
    static let infoBoxExclamationIcon = ImageNameIdentifier(rawValue: "Exclamation")
    static let iconArrowUp = ImageNameIdentifier(rawValue: "ExternalLink")
    static let iconFail = ImageNameIdentifier(rawValue: "Fail")
    static let close = ImageNameIdentifier(rawValue: "Close")
}

/// Provides access to images defined in Assets. The interface is designed to allow a theme context
/// to provide alternative versions without having to change the client code, so far we don't need that yet.
struct Images {
    static let regular = Images()
    var onboardingActivePageIndicator: UIImage = .init(existing: .onboardingActivePageIndicator)
    var onboardingInactivePageIndicator: UIImage = .init(existing: .onboardingInactivePageIndicator)
    var onboardingPage1: UIImage = .init(existing: .onboardingPage1)
    var onboardingPage2: UIImage = .init(existing: .onboardingPage2)
    var onboardingPage3: UIImage = .init(existing: .onboardingPage3)
    var pinEntrySuccess: UIImage = .init(existing: .pinEntrySuccess)
    var infoBoxExclamationIcon: UIImage = .init(existing: .infoBoxExclamationIcon)
    var iconArrowUp: UIImage = .init(existing: .iconArrowUp)
    var iconFail: UIImage = .init(existing: .iconFail)
    var close: UIImage = .init(existing: .close)
    var externalLinkIcon: UIImage = .init(existing: .iconArrowUp)
}
