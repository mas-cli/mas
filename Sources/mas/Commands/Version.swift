//
//  Version.swift
//  mas
//
//  Created by Andrew Naylor on 20/09/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
    /// Command which displays the version of the mas tool.
    struct Version: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Print version number"
        )

        /// Runs the command.
        func run() throws {
            print(Package.version)
        }
    }
}
