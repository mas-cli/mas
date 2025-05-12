//
// VendorSpec.swift
// masTests
//
// Created by Ben Chatelain on 2019-01-03.
// Copyright © 2019 mas-cli. All rights reserved.
//

private import Nimble
import Quick

@testable private import mas

final class VendorSpec: AsyncSpec {
	override static func spec() {
		describe("vendor command") {
			it("can't find app with unknown ID") {
				await expecta(
					await consequencesOf(try await MAS.Vendor.parse(["999"]).run(searcher: MockAppStoreSearcher()))
				)
					== UnvaluedConsequences(MASError.unknownAppID(999))
			}
		}
	}
}
