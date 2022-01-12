//
//  ValidationError.swift
//  IDWallet
//
//  Created by Michael Utech on 07.12.21.
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
