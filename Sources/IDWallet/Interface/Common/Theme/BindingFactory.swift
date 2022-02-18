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
import Combine

enum Binding {
    case cancellable(subscription: AnyCancellable)
    case control(_: UIControl, target: NSObject, action: Selector, event: UIControl.Event)
    case custom(deactive: () -> Void)
}

protocol BindingFactory {
    func addControlledBinding(_ binding: Binding)
}

extension BindingFactory {
    func bind(control: UIControl, target: NSObject, action: Selector, for event: UIControl.Event) {
        control.addTarget(target, action: action, for: event)
        addControlledBinding(.control(control, target: target, action: action, event: event))
    }
    
    func bind(subscriptions: [AnyCancellable]) {
        for subscription in subscriptions {
            addControlledBinding(.cancellable(subscription: subscription))
        }
    }
    
    func bind(activate: () -> Void, deactivate: @escaping () -> Void) {
        activate()
        addControlledBinding(.custom(deactive: deactivate))
    }
}
