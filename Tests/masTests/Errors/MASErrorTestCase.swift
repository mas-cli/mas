//
//  MASErrorTestCase.swift
//  masTests
//
//  Created by Ben Chatelain on 2/11/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

import Foundation
import XCTest

@testable import mas

class MASErrorTestCase: XCTestCase {
    private let errorDomain = "MAS"
    private var error: MASError!
    private var nserror: NSError!

    /// Convenience property for setting the value which will be use for the localized description
    /// value of the next NSError created.
    ///
    /// Only used when the NSError does not have a user info
    /// entry for localized description.
    private var localizedDescription: String {
        get { "dummy value" }
        set {
            NSError.setUserInfoValueProvider(forDomain: errorDomain) { _, _ in
                newValue
            }
        }
    }

    override func setUp() {
        super.setUp()
        MAS.initialize()
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
        error = .alreadySignedIn(asAppleID: "person@example.com")
        XCTAssertEqual(error.description, "Already signed in as person@example.com")
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
        error = .notInstalled(appID: 123)
        XCTAssertEqual(error.description, "No apps installed with app ID 123")
    }

    func testUninstallFailed() {
        error = .uninstallFailed(error: nil)
        XCTAssertEqual(error.description, "Uninstall failed")
    }

    func testNoData() {
        error = .noData
        XCTAssertEqual(error.description, "Service did not return data")
    }

    func testJsonParsing() {
        error = .jsonParsing(data: nil)
        XCTAssertEqual(error.description, "Received empty response")
    }
}
