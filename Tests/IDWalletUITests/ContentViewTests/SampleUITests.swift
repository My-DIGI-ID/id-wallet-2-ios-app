import XCTest

class SampleUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testContentView_WhenAppLaunches_MustNotFails() throws {
        // Initial States
        let app = XCUIApplication()
        
        // Actions
        app.launch()

        // Expectations
    }

    func testContentView_WhenAppLaunches_MustYieldExpectedPerformance() throws {
        // Initial States
        
        // Actions
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
        
        // Expectations
    }
}
