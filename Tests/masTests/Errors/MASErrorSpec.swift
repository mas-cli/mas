//
//  MASErrorSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2/11/18.
//  Copyright © 2018 Andrew Naylor. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public class MASErrorSpec: QuickSpec {
    private static let error = NSError(domain: "MAS", code: 999, userInfo: [NSLocalizedDescriptionKey: "foo"])

    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("mas error") {
            it("NotSignedIn") {
                expect(MASError.notSignedIn.description) == "Not signed in"
            }

            it("SignInFailed") {
                expect(MASError.signInFailed(error: nil).description) == "Sign in failed"
            }

            it("SignInFailedError") {
                expect(MASError.signInFailed(error: Self.error).description) == "Sign in failed: foo"
            }

            it("AlreadySignedIn") {
                expect(MASError.alreadySignedIn(asAppleID: "person@example.com").description)
                    == "Already signed in as person@example.com"
            }

            it("PurchaseFailed") {
                expect(MASError.purchaseFailed(error: nil).description) == "Download request failed"
            }

            it("PurchaseFailedError") {
                expect(MASError.purchaseFailed(error: Self.error).description) == "Download request failed: foo"
            }

            it("DownloadFailed") {
                expect(MASError.downloadFailed(error: nil).description) == "Download failed"
            }

            it("DownloadFailedError") {
                expect(MASError.downloadFailed(error: Self.error).description) == "Download failed: foo"
            }

            it("NoDownloads") {
                expect(MASError.noDownloads.description) == "No downloads began"
            }

            it("Cancelled") {
                expect(MASError.cancelled.description) == "Download cancelled"
            }

            it("SearchFailed") {
                expect(MASError.searchFailed.description) == "Search failed"
            }

            it("NoSearchResultsFound") {
                expect(MASError.noSearchResultsFound.description) == "No apps found"
            }

            it("NoVendorWebsite") {
                expect(MASError.noVendorWebsite.description) == "App does not have a vendor website"
            }

            it("NotInstalled") {
                expect(MASError.notInstalled(appID: 123).description) == "No apps installed with app ID 123"
            }

            it("UninstallFailed") {
                expect(MASError.uninstallFailed(error: nil).description) == "Uninstall failed"
            }

            it("NoData") {
                expect(MASError.noData.description) == "Service did not return data"
            }

            it("JsonParsing") {
                expect(MASError.jsonParsing(data: Data()).description) == "Unable to parse response as JSON:\n"
            }
        }
    }
}
