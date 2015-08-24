//
//  Install.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

struct InstallCommand: CommandType {
    let verb = "install"
    let function = "Install from the Mac App Store"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        let optionsResult = InstallOptions.evaluate(mode)
            
        switch optionsResult {
        case let .Failure(error):
            return .Failure(error)
            
        case let .Success(options):
            if let error = download(options.value.appId) {
                return .failure(CommandantError.CommandError(Box(error)))
            }
            
            return .success(())
        }
    }
}

struct InstallOptions: OptionsType {
    let appId: UInt64
    
    static func create(appId: Int) -> InstallOptions {
        return InstallOptions(appId: UInt64(appId))
    }
    
    static func evaluate(m: CommandMode) -> Result<InstallOptions, CommandantError<MASError>> {
        return create
            <*> m <| Option(key: nil, defaultValue: nil, usage: "the app ID to install")
    }
}