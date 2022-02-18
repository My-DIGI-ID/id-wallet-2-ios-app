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

extension CALayer {
    // See https://stackoverflow.com/a/48489506/1479608
    func applySketchShadow(
        color: UIColor = .shadow,
        offsetX: CGFloat = 0,
        offsetY: CGFloat = 0,
        blur: CGFloat = 80,
        spread: CGFloat = 0) {
            
            masksToBounds = false
            shadowColor = color.cgColor
            shadowOffset = CGSize(width: offsetX, height: offsetY)
            shadowRadius = blur * 0.5
            
            if spread == 0 {
                shadowPath = nil
            } else {
                let deltaX = -spread
                let rect = bounds.insetBy(dx: deltaX, dy: deltaX)
                shadowPath = UIBezierPath(rect: rect).cgPath
            }
        }
}
