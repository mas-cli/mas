//
//  ListSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class ListSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("list command") {
            it("lists apps") {
                expect {
                    try Mas.List.parse([]).run(appLibrary: AppLibraryMock())
                }
                .toNot(throwError())
            }
        }
    }
}
