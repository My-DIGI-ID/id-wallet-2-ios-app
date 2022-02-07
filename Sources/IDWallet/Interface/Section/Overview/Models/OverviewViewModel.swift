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

struct OverviewViewModel {

    typealias ButtonModel = (title: String, action: UIAction)
    typealias DataRow = (title: String, value: String)

    let header: String
    let subHeader: String
    let title: String
    let imageURL: String

    var buttons: [ButtonModel]
    var rows: [DataRow]

    internal init(header: String, subHeader: String, title: String, imageURL: String, buttons: [OverviewViewModel.ButtonModel], data: [DataRow]) {
        self.header = header
        self.subHeader = subHeader
        self.title = title
        self.imageURL = imageURL
        self.buttons = buttons
        self.rows = data
    }
}
