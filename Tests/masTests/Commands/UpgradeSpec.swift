//
//  UpgradeSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class UpgradeSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("upgrade command") {
            it("finds no upgrades") {
                expect(
                    consequencesOf(
                        try MAS.Upgrade.parse([])
                            .run(appLibrary: MockAppLibrary(), searcher: MockAppStoreSearcher())
                    )
                )
                    == (nil, "", "")
            }
        }
    }
}
