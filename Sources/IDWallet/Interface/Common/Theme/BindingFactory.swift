//
//  BindingFactory.swift
//  IDWallet
//
//  Created by Michael Utech on 23.12.21.
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
