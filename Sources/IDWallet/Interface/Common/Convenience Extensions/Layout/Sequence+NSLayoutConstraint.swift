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

import Foundation
import UIKit

extension Sequence where Element == String {
    public func constraints(with viewMap: [String: Any], metrics metricMap: [String: Any]? = nil, options: NSLayoutConstraint.FormatOptions = []) -> [NSLayoutConstraint] {
        flatMap {
            NSLayoutConstraint.constraints(
                withVisualFormat: $0,
                options: options,
                metrics: metricMap,
                views: viewMap
            )
        }
    }
}

extension Sequence where Element == NSLayoutConstraint {
    @inlinable
    public func activate() {
        Element.activate(.init(self))
    }
    @inlinable
    public func deactivate() {
        Element.deactivate(.init(self))
    }
}
