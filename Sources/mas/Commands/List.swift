//
//  List.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser

extension Mas {
    /// Command which lists all installed apps.
    struct List: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Lists apps from the Mac App Store which are currently installed"
        )

        /// Runs the command.
        func run() throws {
            let result = run(appLibrary: MasAppLibrary())
            if case .failure = result {
                try result.get()
            }
        }

        func run(appLibrary: AppLibrary) -> Result<Void, MASError> {
            let products = appLibrary.installedApps
            if products.isEmpty {
                printError("No installed apps found")
                return .success(())
            }

            let output = AppListFormatter.format(products: products)
            print(output)

            return .success(())
        }
    }
}
