//
//  HomeSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-29.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class HomeSpec: AsyncSpec {
    override public static func spec() {
        describe("home command") {
            it("can't find app with unknown ID") {
                await expecta(
                    await consequencesOf(try await MAS.Home.parse(["999"]).run(searcher: MockAppStoreSearcher()))
                )
                    == (MASError.unknownAppID(999), "", "")
            }
        }
    }
}
