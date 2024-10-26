//
//  List.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension MAS {
    /// Command which lists all installed apps.
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "List apps installed from the Mac App Store for the Apple ID of the current macOS user"
        )

        /// Runs the command.
        func run() throws {
            try run(appLibrary: SoftwareMapAppLibrary())
        }

        func run(appLibrary: AppLibrary) throws {
            let products = appLibrary.installedApps
            if products.isEmpty {
                printError("No installed apps found")
            } else {
                print(AppListFormatter.format(products: products))
            }
        }
    }
}
