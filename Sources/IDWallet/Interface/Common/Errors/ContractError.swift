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

import CocoaLumberjackSwift
import Foundation
import UIKit

enum ContractError: Error, CustomStringConvertible {
    
    // Cases
    
    case unspecified(
        file: StaticString = #file, line: UInt = #line)
    
    case preconditionUnsatisfied(
        _ operation: String, condition: String, file: StaticString = #file, line: UInt = #line)
    
    case guardAssertionFailed(
        _ message: String? = nil, file: StaticString = #file, line: UInt = #line)
    
    case unsupportedApiChange(
        _ feature: String? = nil, file: StaticString = #file, line: UInt = #line)
    
    case failedToCallSuper(
        _ instance: Any, feature: String, file: StaticString = #file, line: UInt = #line)
    
    case missingFont(
        _ name: String, size: CGFloat, file: StaticString = #file, line: UInt = #line)
    
    case missingImage(
        _ name: String, file: StaticString = #file, line: UInt = #line)
    
    case missingColor(
        _ name: String, file: StaticString = #file, line: UInt = #line)
    
    // MARK: - CustomStringConvertible
    
    var description: String {
        switch self {
        case .unspecified:
            return format("Unspecified")
            
        case .preconditionUnsatisfied(let operation, let condition, _, _):
            return format("\(operation): precondition \(condition) is not satisfied")
            
        case .guardAssertionFailed(let message, _, _):
            return format("Guarded assertion failed\(message == nil ? "" : ": \(message!)")")
            
        case .unsupportedApiChange(let feature, _, _):
            return format("Unsupported API change\(feature == nil ? "" : ": \(feature!)")")
            
        case .failedToCallSuper(let instance, let feature, _, _):
            return format(
                "\(String(describing: type(of: instance))).\(feature) implementation failed to call super")
            
        case .missingFont(let name, let size, _, _):
            return format("Required font \(name) at size \(size) not available")
            
        case .missingImage(let name, _, _):
            return format("Required image \(name) not available")
            
        case .missingColor(let name, _, _):
            return format("Required color \(name) not available")
        }
    }
    
    // MARK: - Reporting
    
    @discardableResult
    func report() -> Self {
        DDLogError(self.description)
        return self
    }
    
    func fatal() -> Never {
        switch self {
        case
            .unspecified(let file, let line),
            .guardAssertionFailed(_, let file, let line),
            .preconditionUnsatisfied(_, _, let file, let line),
            .unsupportedApiChange(_, let file, let line), .failedToCallSuper(_, _, let file, let line),
            .missingFont(_, _, let file, let line), .missingImage(_, let file, let line),
            .missingColor(_, let file, let line):
            fatalError(self.description, file: file, line: line)
        }
    }
    
    // MARK: - Implementation
    private func format(_ message: String) -> String {
        return "contract violation: \(message)"
    }
}
