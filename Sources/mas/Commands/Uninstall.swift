//
//  Uninstall.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation

extension Mas {
    /// Command which uninstalls apps managed by the Mac App Store.
    struct Uninstall: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Uninstall app installed from the Mac App Store"
        )

        /// Flag indicating that removal shouldn't be performed.
        @Flag(help: "dry run")
        var dryRun = false
        @Argument(help: "ID of app to uninstall")
        var appID: AppID

        /// Runs the uninstall command.
        func run() throws {
            try run(appLibrary: MasAppLibrary())
        }

        func run(appLibrary: AppLibrary) throws {
            let installedApps = appLibrary.installedApps(withAppID: appID)
            guard !installedApps.isEmpty else {
                throw MASError.notInstalled(appID: appID)
            }

            if dryRun {
                for installedApp in installedApps {
                    printInfo("'\(installedApp.appName)' '\(installedApp.bundlePath)'")
                }
                printInfo("(not removed, dry run)")
            } else {
                do {
                    for installedApp in installedApps {
                        try appLibrary.uninstallApp(app: installedApp)
                    }
                } catch {
                    throw MASError.uninstallFailed
                }
            }
        }
    }
}
