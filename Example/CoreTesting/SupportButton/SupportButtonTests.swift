//
//  SupportButtonTests.swift
//  CoreTesting_Tests
//
//  Created by Georgios Sotiropoulos on 29/5/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
import CoreTesting

class SupportButtonTests: XCTestCase {
    func testSupportButton() {
        SnapshotTestConfig.View.free { config in
            // declaring the view outside the closure does not currently work
            // this does not allow us to have a sigle instance of the view
            // and test how it adjusts to changes of font/theme in the runtime
            // we do however test how the view is instantiated in both configurations 
            let button = SupportButton()
            assertImageSnapshot(matching: button, config: config)
        }
    }
}
