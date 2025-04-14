//
//  Uninstall.swift
//  mas
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import Foundation

extension MAS {
    /// Command which uninstalls apps managed by the Mac App Store.
    struct Uninstall: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Uninstall app installed from the Mac App Store"
        )

        /// Flag indicating that removal shouldn't be performed.
        @Flag(help: "Perform dry run")
        var dryRun = false
        @Argument(help: "App ID")
        var appID: AppID

        /// Runs the uninstall command.
        func run() async throws {
            try run(appLibrary: await SoftwareMapAppLibrary())
        }

        func run(appLibrary: AppLibrary) throws {
            guard NSUserName() == "root" else {
                throw MASError.macOSUserMustBeRoot
            }

            guard let username = ProcessInfo.processInfo.sudoUsername else {
                throw MASError.runtimeError("Could not determine the original username")
            }

            guard
                let uid = ProcessInfo.processInfo.sudoUID,
                seteuid(uid) == 0
            else {
                throw MASError.runtimeError("Failed to switch effective user from 'root' to '\(username)'")
            }

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
                guard seteuid(0) == 0 else {
                    throw MASError.runtimeError("Failed to revert effective user from '\(username)' back to 'root'")
                }

                try appLibrary.uninstallApps(atPaths: installedApps.map(\.bundlePath))
            }
        }
    }
}
