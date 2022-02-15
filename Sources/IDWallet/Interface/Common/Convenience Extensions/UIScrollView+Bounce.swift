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

/// Adds extensions to UIScrollView that allow us to determine the bouncing behaviour
extension UIScrollView {
    private var topOffset: CGFloat {
        -safeAreaInsets.top - contentInset.top
    }

    private var bottomOffset: CGFloat {
        guard contentSize.height > frame.size.height else {
            return -safeAreaInsets.top
        }

        return (contentSize.height - frame.size.height) + contentInset.bottom + safeAreaInsets.bottom
    }
    
    /// Returns the total bounced offset as a positive floating-point value or 0.0 if no bounce is currently happening
    var bounceOffset: CGFloat {
        if isBeyondTop {
            return topOffset - contentOffset.y
        } else if isBeyondBottom {
            return contentOffset.y - bottomOffset
        }
        return 0.0
    }

    /// Returns true if the scrollView was scrolled beyond top
    var isBeyondTop: Bool {
        contentOffset.y < topOffset
    }

    /// Returns true if the scrollView was scrolled beyond bottom
    var isBeyondBottom: Bool {
        contentOffset.y > bottomOffset
    }
    
    
    /// Returns true if the scrollView is currently bouncing (isBeyondTop or isBeyondBottom)
    var isBouncing: Bool {
        isBeyondTop || isBeyondBottom
    }
}
