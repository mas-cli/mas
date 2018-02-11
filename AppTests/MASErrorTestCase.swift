//
//  MASErrorTestCase.swift
//  mas-tests
//
//  Created by Ben Chatelain on 2/11/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

//@testable import mas
import XCTest
import Foundation

class MASErrorTestCase: XCTestCase {
    var error: MASError!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testNotSignedIn() {
        error = .notSignedIn
        XCTAssertEqual(error.description, "Not signed in")
    }
}
