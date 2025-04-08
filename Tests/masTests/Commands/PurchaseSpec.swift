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

public final class PurchaseSpec: AsyncSpec {
    override public static func spec() {
        xdescribe("purchase command") {
            it("purchases apps") {
                await expecta(
                    await consequencesOf(
                        try await MAS.Purchase.parse(["999"])
                            .run(appLibrary: MockAppLibrary(), searcher: MockAppStoreSearcher())
                    )
                )
                    == (nil, "", "")
            }
        }
    }
}
