//
//  Install.swift
//  mas
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import CommerceKit

extension Mas {
    /// Installs previously purchased apps from the Mac App Store.
    struct Install: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Install from the Mac App Store"
        )

        @Flag(help: "force reinstall")
        var force = false
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
                if let product = appLibrary.installedApp(forId: appId), !force {
                    printWarning("\(product.appName) is already installed")
                    return false
                }

                return true
            }

            do {
                try downloadAll(appIds).wait()
            } catch {
                return .failure(error as? MASError ?? .downloadFailed(error: error as NSError))
            }

            return .success(())
        }
    }
}
