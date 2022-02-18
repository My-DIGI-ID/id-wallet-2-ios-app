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

private enum Constants {
    enum Image {
        static let fail: UIImage = #imageLiteral(resourceName: "fail")
        static let error: UIImage = #imageLiteral(resourceName: "error")
        static let unkown: UIImage = #imageLiteral(resourceName: "unknownError")
        static let jailbreak: UIImage = #imageLiteral(resourceName: "jailbreak")
        static let noInternet: UIImage = #imageLiteral(resourceName: "noInternet")
        static let timeout: UIImage = #imageLiteral(resourceName: "timeout")
        static let success: UIImage = #imageLiteral(resourceName: "success")
    }
}

extension MessageViewType {
    var image: UIImage {
        switch self {
        case .fail:
            return Constants.Image.fail
        case .error:
            return Constants.Image.error
        case .unknownError:
            return Constants.Image.unkown
        case .jailbreak:
            return Constants.Image.jailbreak
        case .noInternet:
            return Constants.Image.noInternet
        case .timeout:
            return Constants.Image.timeout
        case .success:
            return Constants.Image.success
        }
    }
}
