//
//  OutputListenerSpec.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/8/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Nimble
import Quick

class OutputListenerSpec: QuickSpec {
    override func spec() {
        xdescribe("output listener") {
            it("can intercept a single line written stdout") {
                let output = OutputListener()
                output.openConsolePipe()

                let expectedOutput = "hi there"

                print("hi there", terminator: "")

                // output is async so need to wait for contents to be updated
                expect(output.contents).toEventuallyNot(beEmpty())
                expect(output.contents) == expectedOutput

                output.closeConsolePipe()
            }
            it("can intercept multiple lines written stdout") {
                let output = OutputListener()
                output.openConsolePipe()

                let expectedOutput = """
                hi there

                """

                print("hi there")

                // output is async so need to wait for contents to be updated
                expect(output.contents).toEventuallyNot(beEmpty())
                expect(output.contents) == expectedOutput

                output.closeConsolePipe()
            }
        }
    }
}
