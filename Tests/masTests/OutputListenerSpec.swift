//
//  OutputListenerSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 1/8/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class OutputListenerSpec: QuickSpec {
    override public static func spec() {
        beforeSuite {
            Mas.initialize()
        }
        describe("output listener") {
            it("can intercept a single line written stdout") {
                let output = OutputListener()

                print("hi there", terminator: "")

                expect(output.contents) == "hi there"
            }
            it("can intercept multiple lines written stdout") {
                let output = OutputListener()

                print("hi there")

                expect(output.contents) == """
                    hi there

                    """
            }
        }
    }
}
