//
//  Upgrade.swift
//  mas-cli
//
//  Created by Ben Chatelain on 2018-12-27.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Result
import CommerceKit

/// Command which uninstalls apps managed by the Mac App Store. Relies on the "trash" command from Homebrew.
/// Trash requires el_capitan or higher for core bottles:
/// https://github.com/Homebrew/homebrew-core/blob/master/Formula/trash.rb
public struct UninstallCommand: CommandProtocol {
    public typealias Options = UninstallOptions
    public let verb = "uninstall"
    public let function = "Uninstall apps installed from the Mac App Store"

    public init() {}

    /// Runs the uninstall command
    ///
    /// - Parameter options: UninstallOptions (arguments) for this command
    /// - Returns: Success or an error.
    public func run(_ options: Options) -> Result<(), MASError> {
        let appId = UInt64(options.appId)

        guard let product = installedApp(appId: appId) else {
            return .failure(.notInstalled)
        }

        if options.dryRun {
            printInfo("\(product.appName) \(product.bundlePath)")
            printInfo("(not removed, dry run)")

            return .success(())
        }

        // Use the bundle path to delete the app
        let status = trash(path: product.bundlePath)
        if status {
            return .success(())
        } else {
            return .failure(.searchFailed)
        }
    }

    /// Finds an app by ID from the set of installed apps?
    ///
    /// - Parameter appId: MAS ID for app.
    /// - Returns: Software Product of app if found; nil otherwise.
    func installedApp(appId: UInt64) -> CKSoftwareProduct? {
        let appId = NSNumber(value: appId)

        let softwareMap = CKSoftwareMap.shared()
        return softwareMap.allProducts()?.first { $0.itemIdentifier == appId }
    }

    /// Runs the trash command in another process.
    ///
    /// - Parameter path: Absolute path to the application bundle to uninstall.
    /// - Returns: true on success; fail on error
    func trash(path: String) -> Bool {
        let binaryPath = "/usr/local/bin/trash"
        let process = Process()
        let stdout = Pipe()
        let stderr = Pipe()

        process.standardOutput = stdout
        process.standardError = stderr
        process.arguments = [path]

        if #available(OSX 10.13, *) {
            process.executableURL = URL(fileURLWithPath: binaryPath)
            do {
                try process.run()
            } catch {
                printInfo("Unable to launch trash command")
                return false
            }
        } else {
            process.launchPath = binaryPath
            process.launch()
        }

//        process.terminationHandler = { (process) in
//            print("\ndidFinish: \(!process.isRunning)")
//        }

        process.waitUntilExit()

        if process.terminationStatus == 0 {
            return true
        } else {
            let reason = process.terminationReason
            let output = stderr.fileHandleForReading.readDataToEndOfFile()
            printInfo("Uninstall failed: \(reason)\n\(String(data: output, encoding: String.Encoding.utf8)!)")
            return false
        }
    }
}

/// Options for the uninstall command.
public struct UninstallOptions: OptionsProtocol {
    /// Numeric app ID
    let appId: Int

    /// Flag indicating that removal shouldn't be performed
    let dryRun: Bool

    static func create(_ appId: Int) -> (_ dryRun: Bool) -> UninstallOptions {
        return { dryRun in
            return UninstallOptions(appId: appId, dryRun: dryRun)
        }
    }

    public static func evaluate(_ m: CommandMode) -> Result<UninstallOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "ID of app to uninstall")
            <*> m <| Switch(flag: nil, key: "dry-run", usage: "dry run")
    }
}
