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

fileprivate extension ImageNameIdentifier {
    static let fail = ImageNameIdentifier(rawValue: "Fail")
    static let error = ImageNameIdentifier(rawValue: "Error")
    static let unkown = ImageNameIdentifier(rawValue: "Unknown")
    static let jailbreak = ImageNameIdentifier(rawValue: "Jailbreak")
    static let noInternet = ImageNameIdentifier(rawValue: "NoInternet")
    static let timeout = ImageNameIdentifier(rawValue: "Timeout")
    static let success = ImageNameIdentifier(rawValue: "Success")
}

extension MessageViewType {
    var image: UIImage {
        switch self {
        case .fail:
            return .init(existing: .fail)
        case .error:
            return .init(existing: .error)
        case .unknownError:
            return .init(existing: .unkown)
        case .jailbreak:
            return .init(existing: .jailbreak)
        case .noInternet:
            return .init(existing: .noInternet)
        case .timeout:
            return .init(existing: .timeout)
        case .success:
            return .init(existing: .success)
        }
    }
}
