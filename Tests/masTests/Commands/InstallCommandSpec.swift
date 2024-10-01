//
//  InstallCommandSpec.swift
//  masTests
//
//  Created by Ben Chatelain on 2018-12-28.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble
import Quick

@testable import mas

public class InstallSpec: QuickSpec {
    override public func spec() {
        beforeSuite {
            Mas.initialize()
        }
        xdescribe("install command") {
            xit("installs apps") {
                expect {
                    try Mas.Install.parse([]).run(appLibrary: AppLibraryMock())
                }
                .to(beSuccess())
            }
        }
    }
}
