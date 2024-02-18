//
//  MASErrorTestCase.swift
//  mas-tests
//
//  Created by Ben Chatelain on 2/11/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

import Foundation
import XCTest

@testable import MasKit

class MASErrorTestCase: XCTestCase {
    private let errorDomain = "MAS"
    var error: MASError!
    var nserror: NSError!

    /// Convenience property for setting the value which will be use for the localized description
    /// value of the next NSError created. Only used when the NSError does not have a user info
    /// entry for localized description.
    var localizedDescription: String {
        get { "dummy value" }
        set {
            NSError.setUserInfoValueProvider(forDomain: errorDomain) { (_: Error, _: String) -> Any? in
                newValue
            }
        }
    }

    override func setUp() {
        super.setUp()
        MasKit.initialize()
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

    func testNoVendorWebsite() {
        error = .noVendorWebsite
        XCTAssertEqual(error.description, "App does not have a vendor website")
    }

    func testNotInstalled() {
        error = .notInstalled
        XCTAssertEqual(error.description, "Not installed")
    }

    func testUninstallFailed() {
        error = .uninstallFailed
        XCTAssertEqual(error.description, "Uninstall failed")
    }

    func testNoData() {
        error = .noData
        XCTAssertEqual(error.description, "Service did not return data")
    }

    func testJsonParsing() {
        error = .jsonParsing(error: nil)
        XCTAssertEqual(error.description, "Unable to parse response JSON")
    }
}
