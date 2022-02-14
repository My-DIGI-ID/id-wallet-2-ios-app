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

///
/// This protocol helps structuring errors such that they can be used for logging and in the UI
///
protocol AppError: CustomStringConvertible {
    /// A short phrase identifying the error type (f.e. "PIN validation error")
    ///
    /// The title is designed to beused in alert titles or as a tag in log messages
    ///
    /// Implementation note: should not contain punctuation
    var title: String { get }
    /// A short phrase identifying the error (f.e. "PIN too short")
    ///
    /// Implementation note: should not contain punctuation
    var problem: String { get }
    /// A more detailed message (one or more sentences) including `problem`.
    ///
    /// Implementation note: See default implementation in `extension AppError` and `extension ValidationError`
    var details: String { get }
}

extension AppError {
    var details: String { "\(problem)." }
    var description: String {
        return "\(title): \(details)"
    }
}
