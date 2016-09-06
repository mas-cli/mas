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
        let results = options.appIds.map { (id) -> Result<(), MASError> in
            if let error = download(id) {
                return .Failure(error)
            } else {
                return .Success()
            }
        }
        // See if at least one of the downloads failed
        let errorIndex = results.indexOf {
            if case .Failure(_) = $0 {
                return true
            }
            return false
        }
        // And return an overrall general failure if there're failed downloads
        if let _ = errorIndex {
            return .Failure(MASError(code: .DownloadFailed))
        } else {
            return .Success()
        }
    }
}

struct InstallOptions: OptionsType {
    let appIds: [UInt64]
    
    static func create(appIds: [Int]) -> InstallOptions {
        return InstallOptions(appIds: appIds.map{UInt64($0)})
    }
    
    static func evaluate(m: CommandMode) -> Result<InstallOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "the list of app IDs to install")
    }
}