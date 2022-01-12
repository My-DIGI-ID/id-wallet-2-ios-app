//
//  DevicePinEntryProcessTest.swift
//  IDWalletTests
//
//  Created by Michael Utech on 08.12.21.
//

import IDWallet
import XCTest

class DevicePinEntryProcessTest: XCTestCase {

  override func setUpWithError() throws {
    continueAfterFailure = false
    XCUIApplication().launch()

    // All tests expect the device PIN entry screen to be presented
    try navigateToDevicePinEntry()
  }

  override func tearDownWithError() throws {

  }

  /// Verifies that the UI presents the required information and actions in its initial state
  func testPinEntryProcess_whenNoDigitsEntered_MustAllowAddingDigitsNotCommitNotDelete() throws {

    // Expectation: Texts match setting for initial PIN entry
    let expectedTexts = PinEntryViewModel.Presentation.initialPinEntry
    XCTAssertEqual(navigationTitleLabel().label, expectedTexts.title)
    XCTAssertEqual(actionTitleLabel().label, expectedTexts.heading)
    XCTAssertEqual(actionInstructionsLabel().label, expectedTexts.subHeading)
    XCTAssertEqual(commitButton().label, expectedTexts.commitActionTitle)

    // Expectation: User can add digits but not delete or commit
    for index in 0...9 {
      let element = numberPadCodeCharKey(key: String(index))
      XCTAssertTrue(element.exists)
      XCTAssertEqual(element.isEnabled, true)
    }

    let deleteKey = numberPadDeleteKey()
    XCTAssertTrue(deleteKey.exists)
    XCTAssertEqual(deleteKey.isEnabled, false)

    let commitButton = commitButton()
    XCTAssertTrue(commitButton.exists)
    XCTAssertEqual(commitButton.isEnabled, false)
  }

  /// Verifies that the UI presents the required information and actions in its initial state
  func testPinEntryProcess_whenSomeDigitsEntered_MustAllowAddingAndDeletingDigitsNotCommit() throws {
    // Actions

    enterCode(code: [1, 2])

    // Expectation: User can add and delete digits or commit
    for index in 0...9 {
      let element = numberPadCodeCharKey(key: String(index))
      XCTAssertTrue(element.exists)
      XCTAssertEqual(element.isEnabled, true)
    }

    let deleteKey = numberPadDeleteKey()
    XCTAssertTrue(deleteKey.exists)
    XCTAssertEqual(deleteKey.isEnabled, true)

    let commitButton = commitButton()
    XCTAssertTrue(commitButton.exists)
    XCTAssertEqual(commitButton.isEnabled, false)
  }

  /// Verifies that the UI presents the required information and actions in its initial state
  func testPinEntryProcess_whenAllDigitsEntered_MustAllowDeletingDigitsAndCommitNotAdd() throws {
    // Actions

    enterCode(code: [1, 2, 3, 4, 5, 6])

    // Expectation: User can add and delete digits or commit
    for index in 0...9 {
      let element = numberPadCodeCharKey(key: String(index))
      XCTAssertTrue(element.exists)
      XCTAssertEqual(element.isEnabled, false)
    }

    let deleteKey = numberPadDeleteKey()
    XCTAssertTrue(deleteKey.exists)
    XCTAssertEqual(deleteKey.isEnabled, true)

    let commitButton = commitButton()
    XCTAssertTrue(commitButton.exists)
    XCTAssertEqual(commitButton.isEnabled, true)
  }

  func testPinEntryProcess_whenFirstPinEntered_MustPresentConfirmationPinEntry() throws {
    // Actions

    enterCode(code: [1, 2, 3, 4, 5, 6])
    commit()

    // Expectation: Texts match setting for initial PIN entry
    let expectedTexts = PinEntryViewModel.Presentation.confirmationPinEntry
    XCTAssertEqual(navigationTitleLabel().label, expectedTexts.title)
    XCTAssertEqual(actionTitleLabel().label, expectedTexts.heading)
    XCTAssertEqual(actionInstructionsLabel().label, expectedTexts.subHeading)
    XCTAssertEqual(commitButton().label, expectedTexts.commitActionTitle)

    // Expectation: User can add digits but not delete or commit
    for index in 0...9 {
      let element = numberPadCodeCharKey(key: String(index))
      XCTAssertTrue(element.exists)
      XCTAssertEqual(element.isEnabled, true)
    }

    let deleteKey = numberPadDeleteKey()
    XCTAssertTrue(deleteKey.exists)
    XCTAssertEqual(deleteKey.isEnabled, false)

    let commitButton = commitButton()
    XCTAssertTrue(commitButton.exists)
    XCTAssertEqual(commitButton.isEnabled, false)
  }

  func testPinEntryProcess_whenPinConfirmedIncorrectly_MustPresentFailure() throws {
    // Actions

    enterCode(code: [1, 2, 3, 4, 5, 6])
    commit()
    enterCode(code: [2, 3, 4, 5, 6, 1])
    commit()

    // Expectation: Alert appears with the expected message

    let alertElements = XCUIApplication().alerts["Die Zugangscodes stimmen nicht überein"].scrollViews.otherElements
    let predicate = NSPredicate(format: "label BEGINSWITH %@", "Bitte bestätige deinen Zugangscode noch einmal")
    let label = alertElements.staticTexts.matching(predicate)
    XCTAssertTrue(label.element.exists)
  }

  func testPinEntryProcess_whenPinConfirmedCorrectly_MustPresentSuccess() throws {
    // Actions

    enterCode(code: [1, 2, 3, 4, 5, 6])
    commit()
    enterCode(code: [1, 2, 3, 4, 5, 6])
    commit()

    // Expectation: The success page is presented

    XCTAssertEqual(successHeadingLabel().label, "ID Wallet eingerichtet")
  }
}

// MARK: - Test Parameters

extension DevicePinEntryProcessTest {
  var expectedPinCodeLength: UInt { 6 }
}

// MARK: - Actions

extension DevicePinEntryProcessTest {
  func navigateToDevicePinEntry() throws {
    onboardingStartPinEntryButton().tap()
    introStartPinEntryButton().tap()
  }

  func commit() {
    let button = commitButton()
    button.tap()
  }

  func enterCodeDigit(digit: UInt) {
    guard digit >= 0 && digit <= 9 else { fatalError() }

    numberPadCodeCharKey(key: String(digit)).tap()
  }

  func enterCode(code: [UInt]) {
    for digit in code {
      enterCodeDigit(digit: digit)
    }
  }

  func deleteLastCodeDigit() {
    numberPadDeleteKey().tap()
  }

  func deleteCodeDigits(count: UInt) {
    for _ in 1...count { deleteLastCodeDigit() }
  }
}

// MARK: - Element Access

extension DevicePinEntryProcessTest {
  var app: XCUIApplication { XCUIApplication() }

  typealias PinEntryViewID = PinEntryViewController.ViewID
  typealias OnboardViewID = OnboardingViewController.ViewID
  typealias IntroViewID = PinEntryIntroViewController.ViewID
  typealias SuccessViewID = PinEntrySuccessViewController.ViewID

  func onboardingStartPinEntryButton() -> XCUIElement {
    return app.buttons[OnboardViewID.startButton.key]
  }

  func introStartPinEntryButton() -> XCUIElement {
    return app.buttons[IntroViewID.commitButton.key]
  }

  func successHeadingLabel() -> XCUIElement {
    return app.staticTexts[SuccessViewID.headingLabel.key]
  }

  func navigationTitleLabel() -> XCUIElement {
    return app.staticTexts[PinEntryViewID.titleLabel.key]
  }

  func actionTitleLabel() -> XCUIElement {
    return app.staticTexts[PinEntryViewID.headingLabel.key]
  }

  func actionInstructionsLabel() -> XCUIElement {
    return app.staticTexts[PinEntryViewID.subHeadingLabel.key]
  }

  func pinCodeDigitView(index: UInt) -> XCUIElement {
    return app.otherElements["PinCodeDigitView_\(index)"]
  }

  func numberPadCodeCharKey(key: String) -> XCUIElement {
    return app.otherElements["Key_CodeChar_\(key)"]
  }

  func numberPadDeleteKey() -> XCUIElement {
    return app.buttons["Key_Delete"]
  }

  func commitButton() -> XCUIElement {
    return app.buttons[PinEntryViewID.commitButton.key]
  }

  func cancelButton() -> XCUIElement {
    return app.buttons[PinEntryViewID.cancelButton.key]
  }
}
