//
//  PinEntryViewModel.swift
//  IDWallet
//
//  Created by Michael Utech on 07.12.21.
//

import CocoaLumberjackSwift
import Combine
import Foundation

class PinEntryViewModel {
  // swiftlint:disable force_try
  static let allowOnlyDigitsRegExp: NSRegularExpression = try! NSRegularExpression(
    pattern: "^[0-9]+$",
    options: NSRegularExpression.Options())
  // swiftlint:enable force_try

  // MARK: - Storage

  // MARK: Configuration

  /// The minimum valid length of a PIN
  let minimumLength: UInt?

  /// The maximum valid length of a PIN
  let maximumLength: UInt?

  let revealLastCharacterDuration: CGFloat?

  /// An optional regular expression defining valid PIN characters
  let characterValidation: NSRegularExpression?

  // MARK: Internal State

  private var clearTextPin: String = ""

  private let originalPin: String? = nil

  private let handleResult: (PinEntryViewModel.Result, PinEntryViewController) -> Void

  // MARK: - Initialization

  /// Initializes the view model with the specified parameters
  ///
  /// - Parameter presentation: Presentation related parameters
  /// - Parameter resultHandler: A closure called with the result when the entry process is finished
  /// - Parameter maximumLength: The maximum length of the PIN in characters
  /// - Parameter minimumLength: The minimum length of the PIN in characters
  /// - Parameter originalPin: If defined: will be used by `commit` to compare the entered PIN with  `originalPin`
  /// - Parameter revealLastCharacterDuration The duration for how long the last typed character
  ///     is displayed as clear text (not yet implemented)
  /// - Parameter characterValidation: A regular expression defining the set of valid characters for
  ///     the PIN, applicable to a single character, defaults to digits
  required init(
    presentation: PinEntryViewModel.Presentation,
    resultHandler: @escaping (PinEntryViewModel.Result, PinEntryViewController) -> Void,
    maximumLength: UInt?,
    minimumLength: UInt?,
    originalPin: String? = nil,
    revealLastCharacterDuration: CGFloat? = nil,
    characterValidation: NSRegularExpression? = allowOnlyDigitsRegExp
  ) {
    assert(maximumLength == nil || minimumLength == nil || minimumLength! <= maximumLength!)

    // Configuration
    self.presentation = presentation
    self.maximumLength = maximumLength
    self.minimumLength = minimumLength
    self.characterValidation = characterValidation
    self.handleResult = resultHandler
    self.revealLastCharacterDuration = revealLastCharacterDuration

    // Internal State
    self.clearTextPin = ""

    // Published State
    self.pin = []
    self.canAdd = false
    self.canRemove = false
    self.canCommit = false

    updateStateForPinChange()
  }

  // MARK: - Exposed State

  // Presentation related parameters
  @Published var presentation: PinEntryViewModel.Presentation

  /// Indicates whether a `commit` action can currently be performed
  @Published var canCommit: Bool = false

  /// Indicates whether an `add` action can currently be performed
  @Published var canAdd: Bool

  /// Indicates whether a `remove` action can currently be performed
  @Published var canRemove: Bool

  /// Representation of the PIN that does not reveal its contents (except the last character if so configured)
  @Published var pin: [PinCharacterRepresentation]

  // MARK: - Exposed Actions

  /// Adds a character to the end of the current PIN code. Requires `canAdd`
  ///
  /// - Parameter character: a valid PIN code character to be added
  func add(_ character: String) {
    guard isValidPinCharacter(character) else {
      ContractError.preconditionUnsatisfied("add(c)", condition: "c is valid PIN character").fatal()
    }
    guard canAdd else {
      ContractError.preconditionUnsatisfied("add(_)", condition: "canAdd").fatal()
    }

    clearTextPin += character
    updateStateForPinChange()
  }

  /// Removes the last character from the current PIN code. Requires `canRemove`
  func remove() {
    guard canRemove else {
      ContractError.preconditionUnsatisfied("remove()", condition: "canRemove").fatal()
    }
    clearTextPin.removeLast()
    updateStateForPinChange()
  }

  func commit(_ viewController: PinEntryViewController) {
    guard canCommit else {
      ContractError.preconditionUnsatisfied("commit()", condition: "canCommit").fatal()
    }

    self.handleResult(Result.pin(pin: self.clearTextPin, viewModel: self), viewController)
  }

  func cancel(_ viewController: PinEntryViewController) {
    self.handleResult(Result.cancelled(viewModel: self), viewController)
  }

  // MARK: - Support

  private func updateStateForPinChange() {
    canCommit =
      ((minimumLength == nil || pin.count >= minimumLength!)
        && (maximumLength == nil || pin.count <= maximumLength!) && isValidPin(self.clearTextPin))
    canAdd = maximumLength == nil || clearTextPin.count < maximumLength!
      canRemove = !clearTextPin.isEmpty
    var newPin: [PinCharacterRepresentation] = []
    for _ in 0..<clearTextPin.count {
      newPin.append(.setHidden)
    }
    if let minimumLength = minimumLength, minimumLength > clearTextPin.count {
      newPin.append(.unsetActive)
      let countUnset = minimumLength - UInt(clearTextPin.count) - 1
      for _ in 0..<countUnset {
        newPin.append(.unset)
      }
    }
    pin = newPin
  }
}

// MARK: - Validation

extension PinEntryViewModel {

  private func validatePinCharacter(_ character: String) throws {
    switch character.count {
    case 0:
      throw PinValidationError.tooShort(actual: 0, expected: 1)
    case 1:
      if let regex = characterValidation {
        let range = NSRange(location: 0, length: character.count)
        let matches = regex.matches(
          in: character,
          options: NSRegularExpression.MatchingOptions(),
          range: range)
          if matches.isEmpty {
          // No problem to let the character enter logs, since it's not valid and reveals nothing
          throw PinValidationError.invalidPinCharacter(
            actual: character,
            expected: String.localizedStringWithFormat(
              NSLocalizedString(
                "match for /%s/", comment: "regular expression as description for expectation"),
              regex.pattern))
        }
      }
    default:
      throw PinValidationError.tooLong(actual: UInt(character.count), expected: 1)
    }
  }

  func isValidPinCharacter(_ character: String) -> Bool {
    do {
      try validatePinCharacter(character)
      return true
    } catch {
      return false
    }
  }

  private func validatePin(_ pin: String, confirmationPin: String? = nil) throws {
    if let min = minimumLength {
      if pin.count < min {
        throw PinValidationError.tooShort(actual: UInt(pin.count), expected: min)
      }
    }
    if let max = maximumLength {
      if pin.count > max {
        throw PinValidationError.tooLong(actual: UInt(pin.count), expected: max)
      }
    }
  }

  private func isValidPin(_ pin: String) -> Bool {
    do {
      try validatePin(pin)
      return true
    } catch {
      return false
    }
  }
}

// MARK: - Convenience Initializers

extension PinEntryViewModel {

  static func viewModelForInitialPinEntry(
    presentation: PinEntryViewModel.Presentation = .initialPinEntry,
    resultHandler: @escaping (PinEntryViewModel.Result, PinEntryViewController) -> Void,
    length: UInt = 6
  ) -> PinEntryViewModel {
    return PinEntryViewModel(
      presentation: presentation,
      resultHandler: resultHandler,
      length: length
    )
  }

  func viewModelForConfirmation(
    presentation: PinEntryViewModel.Presentation = .confirmationPinEntry,
    resultHandler: @escaping (PinEntryViewModel.Result, PinEntryViewController) -> Void
  ) -> PinEntryViewModel {
    return PinEntryViewModel(
      presentation: presentation,
      resultHandler: resultHandler,
      maximumLength: self.maximumLength,
      minimumLength: self.minimumLength,
      originalPin: self.clearTextPin
    )
  }

  /// Initializes the view model with the specified parameters
  ///
  /// - Parameter presentation: Presentation related parameters
  /// - Parameter resultHandler: A closure called with the result when the entry process is finished
  /// - Parameter length: The length of the PIN in characters
  /// - Parameter revealLastCharacterDuration The duration for how long the last typed character
  ///     is displayed as clear text (not yet implemented)
  /// - Parameter characterValidation: A regular expression defining the set of valid characters for
  ///     the PIN, applicable to a single character, defaults to digits
  convenience init(
    presentation: PinEntryViewModel.Presentation,
    resultHandler: @escaping (PinEntryViewModel.Result, PinEntryViewController) -> Void,
    length: UInt,
    revealLastCharacterDuration: CGFloat? = nil,
    characterValidation: NSRegularExpression? = allowOnlyDigitsRegExp
  ) {
    self.init(
      presentation: presentation,
      resultHandler: resultHandler,
      maximumLength: length, minimumLength: length,
      revealLastCharacterDuration: revealLastCharacterDuration,
      characterValidation: characterValidation
    )
  }
}

// MARK: - Local Types

extension PinEntryViewModel {

  struct Presentation {
    static var initialPinEntry: PinEntryViewModel.Presentation {
      Presentation(
        title: NSLocalizedString(
          "Richte deine ID Wallet ein", comment: "Navigation context"),
        heading: NSLocalizedString(
          "Zugangscode festlegen", comment: "Action title"),
        subHeading: NSLocalizedString(
          "Den Zugangscode brauchst du bei jeder Nutzung der ID Wallet App",
          comment: "Action instructions"),
        commitActionTitle: NSLocalizedString(
          "Weiter", comment: "Commit button title, next step"),
        themeContext: .main
      )
    }
    static var confirmationPinEntry: PinEntryViewModel.Presentation {
      Presentation(
        title: NSLocalizedString(
          "Richte deine ID Wallet ein", comment: "Navigation context"),
        heading: NSLocalizedString(
          "Zugangscode bestätigen", comment: "Action title"),
        subHeading: NSLocalizedString(
          "Bitte gib jetzt deinen Zugangscode zur Bestätigung erneut ein",
          comment: "Action instructions"),
        commitActionTitle: NSLocalizedString(
          "Bestätigen", comment: "Commit button title, confirm"),
        themeContext: .main
      )
    }

    let title: String
    let heading: String
    let subHeading: String
    let commitActionTitle: String

    let themeContext: ThemeContext
  }

  enum Result: Equatable {
    static func == (lhs: PinEntryViewModel.Result, rhs: PinEntryViewModel.Result) -> Bool {
      switch (lhs, rhs) {
      case (pin(let pinA, _), pin(let pinB, _)) where pinA == pinB:
        return true
      case (cancelled(_), cancelled(_)):
        return true
      default:
        return false
      }
    }

    /// The clear text PIN passing validation and confirmation if performed
    /// - Parameter pin: The validated PIN
    /// - Parameter viewModel: a reference to the view model
    case pin(pin: String, viewModel: PinEntryViewModel)

    /// The PIN entry process was cancelled (presumably by the user)
    /// - Parameter viewModel: a reference to the view model
    case cancelled(viewModel: PinEntryViewModel)
  }
}
