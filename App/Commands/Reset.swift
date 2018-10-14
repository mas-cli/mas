//
//  Reset.swift
//  mas-cli
//
//  Created by Andrew Naylor on 14/09/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import Result
import CommerceKit

struct ResetCommand: CommandProtocol {
    typealias Options = ResetOptions
    let verb = "reset"
    let function = "Resets the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
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
            "storelegacy",
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
        
        if kill.terminationStatus != 0 && options.debug {
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

struct ResetOptions: OptionsProtocol {
    let debug: Bool
    
    static func create(debug: Bool) -> ResetOptions {
        return ResetOptions(debug: debug)
    }
    
    static func evaluate(_ m: CommandMode) -> Result<ResetOptions, CommandantError<MASError>> {
        return create
            <*> m <| Switch(flag: nil, key: "debug", usage: "Enable debug mode")
    }
}
