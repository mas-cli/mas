//
// OpenSpec.swift
// masTests
//
// Created by Ben Chatelain on 2019-01-03.
// Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class OpenSpec: AsyncSpec {
	override public static func spec() {
		describe("open command") {
			it("can't find app with unknown ID") {
				await expecta(
					await consequencesOf(try await MAS.Open.parse(["999"]).run(searcher: MockAppStoreSearcher()))
				)
					== (MASError.unknownAppID(999), "", "")
			}
		}
	}
}
