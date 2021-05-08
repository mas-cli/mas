//
//  OpenSystemCommandMock.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 1/4/19.
//  Copyright © 2019 mas-cli. All rights reserved.
//

import Foundation

@testable import MasKit

class OpenSystemCommandMock: ExternalCommand {
    // Stub out protocol logic
    var succeeded = true
    var arguments: [String]?

    // unused
    var binaryPath = "/dev/null"
    var process = Process()
    var stdoutPipe = Pipe()
    var stderrPipe = Pipe()

    init() {}

    func run(arguments: String...) throws {
        self.arguments = arguments
    }
}
