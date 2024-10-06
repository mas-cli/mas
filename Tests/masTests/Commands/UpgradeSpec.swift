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

public class UpgradeSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("upgrade command") {
            it("upgrades stuff") {
                expect {
                    try Mas.Upgrade.parse([]).run(appLibrary: AppLibraryMock(), storeSearch: StoreSearchMock())
                }
                .toNot(throwError())
            }
        }
    }
}
