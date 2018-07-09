//
//  MASErrorTestCase.swift
//  mas-tests
//
//  Created by Ben Chatelain on 2/11/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

@testable import MasKit
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
        nserror = NSError(domain: errorDomain, code: 999)
        localizedDescription = "foo"
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
        error = .signInFailed(error: nserror)
        XCTAssertEqual(error.description, "Sign in failed: foo")
    }

    func testAlreadySignedIn() {
        error = .alreadySignedIn
        XCTAssertEqual(error.description, "Already signed in")
    }

    func testPurchaseFailed() {
        error = .purchaseFailed(error: nil)
        XCTAssertEqual(error.description, "Download request failed")
    }

    func testPurchaseFailedError() {
        error = .purchaseFailed(error: nserror)
        XCTAssertEqual(error.description, "Download request failed: foo")
    }

    func testDownloadFailed() {
        error = .downloadFailed(error: nil)
        XCTAssertEqual(error.description, "Download failed")
    }

    func testDownloadFailedError() {
        error = .downloadFailed(error: nserror)
        XCTAssertEqual(error.description, "Download failed: foo")
    }

    func testNoDownloads() {
        error = .noDownloads
        XCTAssertEqual(error.description, "No downloads began")
    }

    func testCancelled() {
        error = .cancelled
        XCTAssertEqual(error.description, "Download cancelled")
    }

    func testSearchFailed() {
        error = .searchFailed
        XCTAssertEqual(error.description, "Search failed")
    }

    func testNoSearchResultsFound() {
        error = .noSearchResultsFound
        XCTAssertEqual(error.description, "No results found")
    }
}
