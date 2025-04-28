//
//  InstallSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class InstallSpec: AsyncSpec {
	override public static func spec() {
		xdescribe("install command") {
			it("installs apps") {
				await expecta(
					await consequencesOf(
						try await MAS.Install.parse([]).run(installedApps: [], searcher: MockAppStoreSearcher())
					)
				)
					== (nil, "", "")
			}
		}
	}
}
