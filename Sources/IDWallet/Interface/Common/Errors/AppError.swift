//
//  AppError.swift
//  IDWallet
//
//  Created by Michael Utech on 07.12.21.
//

import CocoaLumberjackSwift
import Foundation

///
/// This protocol helps structuring errors such that they can be used for logging and in the UI
///
protocol AppError: CustomStringConvertible {
  /// A short phrase identifying the error type (f.e. "PIN validation error")
  ///
  /// The title is designed to beused in alert titles or as a tag in log messages
  ///
  /// Implementation note: should not contain punctuation
  var title: String { get }
  /// A short phrase identifying the error (f.e. "PIN too short")
  ///
  /// Implementation note: should not contain punctuation
  var problem: String { get }
  /// A more detailed message (one or more sentences) including `problem`.
  ///
  /// Implementation note: See default implementation in `extension AppError` and `extension ValidationError`
  var details: String { get }
}

extension AppError {
  var details: String { "\(problem)." }
  var description: String {
    return "\(title): \(details)"
  }
}
