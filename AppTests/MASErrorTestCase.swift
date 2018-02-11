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
    private let errorDomain = "MAS"
    var error: MASError!
    var nserror: NSError!

    /// Convenience property for setting the value which will be use for the localized description
    /// value of the next NSError created. Only used when the NSError does not have a user info
    /// entry for localized description.
    var localizedDescription: String {
        get { return "dummy value" }
        set {
            NSError.setUserInfoValueProvider(forDomain: errorDomain) { (error: Error, userInfoKey: String) -> Any? in
                return newValue
            }
        }
    }

    override func setUp() {
        super.setUp()
        nserror = NSError(domain: errorDomain, code: 999) //, userInfo: ["NSLocalizedDescriptionKey": "foo"])
    }

    override func tearDown() {
        nserror = nil
        error = nil
        super.tearDown()
    }

    func testNotSignedIn() {
        error = .notSignedIn
        XCTAssertEqual(error.description, "Not signed in")
    }

    func testSignInFailed() {
        error = .signInFailed(error: nil)
        XCTAssertEqual(error.description, "Sign in failed")
    }

    func testSignInFailedError() {
        localizedDescription = "foo"
        error = .signInFailed(error: nserror)
        XCTAssertEqual("Sign in failed: foo", error.description)
    }
}
