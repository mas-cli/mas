//
//  Install.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

struct InstallCommand: CommandType {
    typealias Options = InstallOptions
    let verb = "install"
    let function = "Install from the Mac App Store"
    
    func run(options: Options) -> Result<(), MASError> {
        // Try to download applications with given identifiers and collect results
        let downloadResults = options.appIds.flatMap(download)

        if downloadResults.count > 0 {
            return .Failure(downloadResults[0])
        }
        
        return .Success()
    }
}

struct InstallOptions: OptionsType {
    let appIds: [UInt64]
    
    static func create(appIds: [Int]) -> InstallOptions {
        return InstallOptions(appIds: appIds.map{UInt64($0)})
    }
    
    static func evaluate(m: CommandMode) -> Result<InstallOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "app ID(s) to install")
    }
}