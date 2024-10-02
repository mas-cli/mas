//
//  OutdatedSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class OutdatedSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("outdated command") {
            it("displays apps with pending updates") {
                expect {
                    try Mas.Outdated.parse(["--verbose"])
                        .run(appLibrary: AppLibraryMock(), storeSearch: StoreSearchMock())
                }
                .toNot(throwError())
            }
        }
    }
}
