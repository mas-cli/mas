//
//  Reset.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/09/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import CommerceKit

/// Kills several macOS processes as a means to reset the app store.
public struct ResetCommand: CommandProtocol {
    public typealias Options = ResetOptions
    public let verb = "reset"
    public let function = "Resets the Mac App Store"

    public init() {}

    /// Runs the command.
    public func run(_ options: Options) -> Result<(), MASError> {
        /*
         The "Reset Application" command in the Mac App Store debug menu performs
         the following steps

         - killall Dock
         - killall storeagent (storeagent no longer exists)
         - rm com.apple.appstore download directory
         - clear cookies (appears to be a no-op)

         As storeagent no longer exists we will implement a slight variant and kill all
         App Store-associated processes
         - storeaccountd
         - storeassetd
         - storedownloadd
         - storeinstalld
         - storelegacy
         */

        // Kill processes
        let killProcs = [
            "Dock",
            "storeaccountd",
            "storeassetd",
            "storedownloadd",
            "storeinstalld",
            "storelegacy"
        ]

        let kill = Process()
        let stdout = Pipe()
        let stderr = Pipe()

        kill.launchPath = "/usr/bin/killall"
        kill.arguments = killProcs
        kill.standardOutput = stdout
        kill.standardError = stderr

        kill.launch()
        kill.waitUntilExit()

        if kill.terminationStatus != 0, options.debug {
            let output = stderr.fileHandleForReading.readDataToEndOfFile()
            printInfo("killall  failed:\r\n\(String(data: output, encoding: String.Encoding.utf8)!)")
        }

        // Wipe Download Directory
        if let directory = CKDownloadDirectory(nil) {
            do {
                try FileManager.default.removeItem(atPath: directory)
            } catch {
                if options.debug {
                    printError("removeItemAtPath:\"\(directory)\" failed, \(error)")
                }
            }
        }

        return .success(())
    }
}

public struct ResetOptions: OptionsProtocol {
    let debug: Bool

    public static func create(debug: Bool) -> ResetOptions {
        return ResetOptions(debug: debug)
    }

    public static func evaluate(_ mode: CommandMode) -> Result<ResetOptions, CommandantError<MASError>> {
        return create
            <*> mode <| Switch(flag: nil, key: "debug", usage: "Enable debug mode")
    }
}
