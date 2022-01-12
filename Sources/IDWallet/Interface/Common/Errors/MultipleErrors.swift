//
//  MultipleErrors.swift
//  IDWallet
//
//  Created by Michael Utech on 10.12.21.
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
