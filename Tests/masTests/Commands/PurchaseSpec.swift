//
//  PurchaseSpec.swift
//  masTests
//
//  Created by Maximilian Blochberger on 2020-03-21.
//  Copyright © 2020 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public final class PurchaseSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            MAS.initialize()
        }
        xdescribe("purchase command") {
            it("purchases apps") {
                expect(
                    consequencesOf(
                        try MAS.Purchase.parse(["999"])
                            .run(appLibrary: MockAppLibrary(), searcher: MockAppStoreSearcher())
                    )
                )
                    == (nil, "", "")
            }
        }
    }
}
