//
//  Images.swift
//  IDWallet
//
//  Created by Michael Utech on 11.12.21.
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

  var externalLinkIcon: UIImage {
    iconArrowUp
  }
}
