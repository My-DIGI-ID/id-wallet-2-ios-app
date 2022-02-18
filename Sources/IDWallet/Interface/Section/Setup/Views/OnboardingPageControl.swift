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

import CocoaLumberjackSwift
import Foundation
import UIKit

class OnboardingPageControl: UIPageControl {
}

// MARK: - Local Types

extension OnboardingPageControl {

  struct IndicatorStyle {
    let image: UIImage
    let tintColor: UIColor?

    static let defaultActive = IndicatorStyle(
      image: ThemeContext.alternative.images.onboardingActivePageIndicator)
    static let defaultInactive = IndicatorStyle(
      image: ThemeContext.alternative.images.onboardingInactivePageIndicator)

    init(image: UIImage, tintColor: UIColor? = nil) {
      self.image = image
      self.tintColor = tintColor
    }

    func applyTo(imageView: UIImageView) {
      if let tintColor = tintColor {
        imageView.image = image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = tintColor
      } else {
        imageView.image = image
      }
    }
  }

  struct Style {
    let themeContext: ThemeContext
    let activeIndicatorStyle: IndicatorStyle
    let inactiveIndicatorStyle: IndicatorStyle

    init(
      _ themeContext: ThemeContext,
      activeIndicatorStyle: IndicatorStyle? = nil,
      inactiveIndicatorStyle: IndicatorStyle? = nil
    ) {
      self.themeContext = themeContext
      self.activeIndicatorStyle =
        activeIndicatorStyle
        ?? OnboardingPageControl.IndicatorStyle(
          image: themeContext.images.onboardingActivePageIndicator)
      self.inactiveIndicatorStyle =
        inactiveIndicatorStyle
        ?? OnboardingPageControl.IndicatorStyle(
          image: themeContext.images.onboardingInactivePageIndicator)
    }

    /// Applies indicator stlyes `pageIndicators` (subviews of a UIPageControl) assuming that
    /// the subview at index `currentPage` is active.
    func applyTo(_ pageIndicatorContentView: UIView, currentPage: UInt, numberOfPages: UInt) {
      guard numberOfPages > 0 else { return }

      guard currentPage < numberOfPages else { ContractError.guardAssertionFailed().fatal() }

      let pageIndicators = pageIndicatorContentView.subviews
      let center = pageIndicatorContentView.center
      let spacing = 10.0
      let width =
        activeIndicatorStyle.image.size.width + Double(numberOfPages - 1)
        * (inactiveIndicatorStyle.image.size.width + spacing)
      let height = max(
        activeIndicatorStyle.image.size.height, inactiveIndicatorStyle.image.size.height)
      pageIndicatorContentView.clipsToBounds = false
      pageIndicatorContentView.superview?.clipsToBounds = false
      var centerX = center.x - width / 2.0
      let centerY = center.y - height / 2.0
      for (index, indicatorView) in pageIndicators.enumerated() {
        var imageView = locateIndicatorImageView(indicatorView)
        if imageView == nil {
          imageView = UIImageView()
          indicatorView.addSubview(imageView!)
        }
        if let imageView = imageView {
          let indicatorStyle = index == currentPage ? activeIndicatorStyle : inactiveIndicatorStyle
          indicatorStyle.applyTo(imageView: imageView)
          imageView.frame.origin = CGPoint(x: centerX, y: centerY)
          centerX += imageView.frame.size.width
        }
      }
    }

    func locateIndicatorImageView(_ view: UIView) -> UIImageView? {
      if let result = view as? UIImageView {
        return result
      }
      return view.subviews.first(where: { $0 is UIImageView }) as? UIImageView
    }
  }
}
