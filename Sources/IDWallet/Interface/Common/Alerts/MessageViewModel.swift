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

enum AlertType {
    case error, fail, unknownError, jailbreak, noInternet, timeout, success
}

protocol MessageModelProtocol {
    typealias ButtonModel = (title: String, action: UIAction)
    var title: String { get }
    var messageType: AlertType { get }
    var header: String { get }
    var text: String { get }
    var buttons: [ButtonModel] { get }
}

struct MessageViewModel: MessageModelProtocol {
    
    var title: String
    var messageType: AlertType
    var header: String
    var text: String
    var buttons: [ButtonModel]
    
    internal init(title: String = "", messageType: MessageType, header: String = "", text: String = "", buttons: [ButtonModel]) {
        self.title = title
        self.messageType = messageType
        self.header = header
        self.text = text
        self.buttons = buttons
    }
}
