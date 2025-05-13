//
// VendorSpec.swift
// masTests
//
// Copyright © 2019 mas-cli. All rights reserved.
//

private import ArgumentParser
@testable private import mas
private import Nimble
import Quick

final class VendorSpec: AsyncSpec {
	override static func spec() {
		describe("vendor command") {
			it("can't find app with unknown ID") {
				await expecta(
					await consequencesOf(try await MAS.Vendor.parse(["999"]).run(searcher: MockAppStoreSearcher()))
				)
					== UnvaluedConsequences(ExitCode(1), "", "Error: No apps found in the Mac App Store for app ID 999\n")
			}
		}
	}
}
