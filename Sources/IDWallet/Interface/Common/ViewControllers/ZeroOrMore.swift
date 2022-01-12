//
//  OneOrMore.swift
//  IDWallet
//
//  Created by Michael Utech on 19.12.21.
//

import Foundation

enum Cardinality {
  case zero
  case one
  case multiple
}

/// Enum providing an easy mechanism to handle cardinalities seamlessly.
///
/// Please note that for convenience ``.none`` is equivalent to ``.some([])`` and
/// ``.one(x)`` is equivalent to ``.some([x]``. ``canonical`` will convert ``.some([])`` and
/// ``.some([x])`` to ``.none`` and ``.one(x)`` respectively. The implementation of ``Equatable``
/// will consider equivalent instances as equal.
enum ZeroOrMore<T: Any>: Sequence {
  typealias Element = T

  struct Iterator: IteratorProtocol {
    private var index = 0
    private let instance: ZeroOrMore<T>

    init(_ instance: ZeroOrMore<T>) {
      self.instance = instance
    }

    mutating func next() -> T? {
      switch instance {
      case .none:
        return nil
      case .one(let result):
        guard index == 0 else { return nil }
        index += 1
        return result
      case .some(let values):
        guard index < values.count else { return nil }
        let result = values[index]
        index += 1
        return result
      }
    }
  }

  case none
  case one(_: T)
  case some(_: [T])

  func makeIterator() -> Iterator {
    Iterator(self)
  }

  var first: T? {
    switch self {
    case .none: return nil
    case .one(let value): return value
    case .some(let values): return values.first
    }
  }

  var cardinality: Cardinality {
    switch self {
    case .none:
      return .zero
    case .one:
      return .one
    case .some(let values):
      switch values.count {
      case 0:
        return .zero
      case 1:
        return .one
      default:
        return .multiple
      }
    }
  }

  var canonical: ZeroOrMore<T> {
    switch self {
    case .none, .one:
      return self

    case .some(let values):
      switch values.count {
      case 0:
        return .none
      case 1:
        return .one(values[0])
      default:
        return self
      }
    }
  }
}

extension ZeroOrMore: Equatable where T: Equatable {
  static func == (lhs: ZeroOrMore<T>, rhs: ZeroOrMore<T>) -> Bool {
    // Not using ``canonical`` to avoid unnecessary array creations
    switch lhs {
    case .none:
      return rhs == .none

    case .one(let value):
      switch rhs {
      case .none:
        return false

      case .one(let other):
        return value == other

      case .some(let others):
        return others.count == 1 && value == others.first!
      }

    case .some(let values):
      switch rhs {
      case .none:
        return values.isEmpty
      case .one(let other):
        return values.count == 1 && values.first! == other
      case .some(let others):
        return values == others
      }
    }
  }
}

extension ZeroOrMore: CustomStringConvertible where T: CustomStringConvertible {
  var description: String {
    return description()
  }

  func description(
    prefix: String? = nil,
    prefixIfOne: String? = nil,
    prefixIfNone: String? = nil,
    separator: String = ", ",
    suffix: String? = nil,
    suffixIfOne: String? = nil,
    suffixIfNone: String? = nil
  ) -> String {
    switch self {
    case .none:
      return withPrefixAndSuffix(
        "",
        prefix: prefixIfNone ?? prefix ?? "",
        suffix: suffixIfNone ?? suffix ?? "")
    case .one(let value):
      return withPrefixAndSuffix(
        value.description, prefix: prefixIfOne ?? prefix ?? "",
        suffix: suffixIfOne ?? suffix ?? "")
    case .some(let values):
      return values.map {
        withPrefixAndSuffix(
          $0.description,
          prefix: prefix ?? "", suffix: suffix ?? "")
      }.joined(separator: separator)
    }
  }

  func withPrefixAndSuffix(_ string: String, prefix: String, suffix: String) -> String {
    return "\(prefix)\(string)\(suffix)"
  }
}
