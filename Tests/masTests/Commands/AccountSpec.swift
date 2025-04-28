//
//  AccountSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class AccountSpec: AsyncSpec {
	override public static func spec() {
		describe("account command") {
			it("displays not supported warning") {
				await expecta(await consequencesOf(try await MAS.Account.parse([]).run()))
					== (error: MASError.notSupported, stdout: "", stderr: "")
			}
		}
	}
}
