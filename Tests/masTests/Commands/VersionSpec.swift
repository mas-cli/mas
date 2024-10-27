//
//  VersionSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import mas

public class VersionSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            MAS.initialize()
        }
        describe("version command") {
            it("displays the current version") {
                expect {
                    try captureStream(stdout) {
                        try MAS.Version.parse([]).run()
                    }
                }
                    == "\(Package.version)\n"
            }
        }
    }
}
