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

class MultipleErrors: Error, AppError {
    static func from(_ errors: [Error]) -> Error? {
        switch errors.compactMap({ $0 }).count {
        case 0:
            return nil
        case 1:
            return errors[0]
        default:
            return MultipleErrors(errors)
        }
    }
    
    var title: String = "Multiple Errors"
    
    var problem: String
    
    let details: String
    
    let errors: [Error]
    
    private init(_ errors: [Error]) {
        self.errors = errors
        problem = String.localizedStringWithFormat(
            NSLocalizedString("%d Errors", comment: "Error count (count > 1)"),
            errors.count
        )
        details = "\(problem): \(errors.map({ "\n - \($0.localizedDescription)" }))"
    }
}
