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

import XCTest

@testable import IDWallet

class IDWalletTests: XCTestCase {
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testViewController_WhenLoaded_MustYieldExpectedValue() throws {
        // Initial States
        // Actions
        // Expectations
    }
    
    func testViewController_WhenProcessIsRunning_MustYieldExpectedPerformance() throws {
        // Initial States
        
        // Actions
        self.measure {
            // Put the code you want to measure the time of here.
        }
        
        // Expectations
    }
}
