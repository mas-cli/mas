//
//  MASErrorSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2/11/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

import Foundation
import XCTest

@testable import mas

class MASErrorSpec: XCTestCase {
    private static let error = NSError(domain: "MAS", code: 999, userInfo: [NSLocalizedDescriptionKey: "foo"])

    override func setUp() {
        super.setUp()
        MAS.initialize()
    }

    func testNotSignedIn() {
        XCTAssertEqual(MASError.notSignedIn.description, "Not signed in")
    }

    func testSignInFailed() {
        XCTAssertEqual(MASError.signInFailed(error: nil).description, "Sign in failed")
    }

    func testSignInFailedError() {
        XCTAssertEqual(MASError.signInFailed(error: Self.error).description, "Sign in failed: foo")
    }

    func testAlreadySignedIn() {
        XCTAssertEqual(
            MASError.alreadySignedIn(asAppleID: "person@example.com").description,
            "Already signed in as person@example.com"
        )
    }

    func testPurchaseFailed() {
        XCTAssertEqual(MASError.purchaseFailed(error: nil).description, "Download request failed")
    }

    func testPurchaseFailedError() {
        XCTAssertEqual(MASError.purchaseFailed(error: Self.error).description, "Download request failed: foo")
    }

    func testDownloadFailed() {
        XCTAssertEqual(MASError.downloadFailed(error: nil).description, "Download failed")
    }

    func testDownloadFailedError() {
        XCTAssertEqual(MASError.downloadFailed(error: Self.error).description, "Download failed: foo")
    }

    func testNoDownloads() {
        XCTAssertEqual(MASError.noDownloads.description, "No downloads began")
    }

    func testCancelled() {
        XCTAssertEqual(MASError.cancelled.description, "Download cancelled")
    }

    func testSearchFailed() {
        XCTAssertEqual(MASError.searchFailed.description, "Search failed")
    }

    func testNoSearchResultsFound() {
        XCTAssertEqual(MASError.noSearchResultsFound.description, "No apps found")
    }

    func testNoVendorWebsite() {
        XCTAssertEqual(MASError.noVendorWebsite.description, "App does not have a vendor website")
    }

    func testNotInstalled() {
        XCTAssertEqual(MASError.notInstalled(appID: 123).description, "No apps installed with app ID 123")
    }

    func testUninstallFailed() {
        XCTAssertEqual(MASError.uninstallFailed(error: nil).description, "Uninstall failed")
    }

    func testNoData() {
        XCTAssertEqual(MASError.noData.description, "Service did not return data")
    }

    func testJsonParsing() {
        XCTAssertEqual(MASError.jsonParsing(data: Data()).description, "Unable to parse response as JSON:\n")
    }
}
