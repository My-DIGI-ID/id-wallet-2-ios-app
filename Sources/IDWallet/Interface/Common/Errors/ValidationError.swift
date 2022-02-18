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

///
/// Errors describing items that failed to pass a validation, usually user input
///
protocol ValidationError: AppError {
    /// A short phrase describing the unsatisfied expectation
    ///
    /// Implementation note: This item may be prefixed with "expected ", see default
    /// implementation of `ValidationError.details`
    var expectation: String? { get }
    /// A short phrase identifying the defect
    ///
    /// Implementation note: This should either identify or represent the invalid item or explain
    /// how it does not match the expectation if the offending item is sensitive
    /// (such as a password that should never appear in error logs)
    ///
    /// Implementation note: This item may be prefixed with "expected ..., got ", see default
    /// implementation of `ValidationError.details`
    var actual: String? { get }
}

extension ValidationError {
    /// Used to implement `details`
    private var expectationFragment: String {
        if let expectation = expectation {
            return String.localizedStringWithFormat(
                NSLocalizedString(
                    ", expected %s", comment: "used to append an expectation phrase to a problem phrase"),
                expectation
            )
        }
        return ""
    }
    /// Used to implement `details`
    var actualFragment: String {
        if let actual = actual {
            if expectation != nil {
                return String.localizedStringWithFormat(
                    NSLocalizedString(
                        ", got %s", comment: "used to append an actual phrase to an expectation phrase"),
                    actual
                )
            }
        }
        return ""
    }
    var details: String {
        return "\(problem)\(expectationFragment)\(actualFragment)."
    }
}
