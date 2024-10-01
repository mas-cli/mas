//
//  Purchase.swift
//  mas
//
//  Created by Jakob Rieck on 24/10/2017.
//  Copyright (c) 2017 Jakob Rieck. All rights reserved.
//

import ArgumentParser
import CommerceKit

extension Mas {
    struct Purchase: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Purchase and download free apps from the Mac App Store"
        )

        @Argument(help: "app ID(s) to install")
        var appIds: [UInt64]

        /// Runs the command.
        func run() throws {
            let result = run(appLibrary: MasAppLibrary())
            if case .failure = result {
                try result.get()
            }
        }

        func run(appLibrary: AppLibrary) -> Result<Void, MASError> {
            // Try to download applications with given identifiers and collect results
            let appIds = appIds.filter { appId in
                if let product = appLibrary.installedApp(forId: appId) {
                    printWarning("\(product.appName) has already been purchased.")
                    return false
                }

                return true
            }

            do {
                try downloadAll(appIds, purchase: true).wait()
            } catch {
                return .failure(error as? MASError ?? .downloadFailed(error: error as NSError))
            }

            return .success(())
        }
    }
}
