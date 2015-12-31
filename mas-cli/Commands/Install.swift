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
        if let error = download(options.appId) {
            return .Failure(error)
        }
        
        return .Success(())
    }
}

struct InstallOptions: OptionsType {
    let appId: UInt64
    
    static func create(appId: Int) -> InstallOptions {
        return InstallOptions(appId: UInt64(appId))
    }
    
    static func evaluate(m: CommandMode) -> Result<InstallOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "the app ID to install")
    }
}