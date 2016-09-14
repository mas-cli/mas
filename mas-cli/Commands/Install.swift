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
        let downloadResults = options.appIds.flatMap { (appId) -> MASError? in
            if let product = installedApp(appId) where !options.forceInstall {
                warn("\(product.appName) is already installed")
                return nil
            }
            
            return download(appId)
        }

        switch downloadResults.count {
        case 0:
            return .Success()
        case 1:
            return .Failure(downloadResults[0])
        default:
            return .Failure(MASError(code: .DownloadFailed))
        }
    }
    
    private func installedApp(appId: UInt64) -> CKSoftwareProduct? {
        let appId = NSNumber(unsignedLongLong: appId)
        
        let softwareMap = CKSoftwareMap.sharedSoftwareMap()
        return softwareMap.allProducts()?.filter { $0.itemIdentifier == appId }.first
    }
}

struct InstallOptions: OptionsType {
    let appIds: [UInt64]
    let forceInstall: Bool
    
    static func create(appIds: [Int], forceInstall: Bool) -> InstallOptions {
        return InstallOptions(appIds: appIds.map{UInt64($0)}, forceInstall: forceInstall)
    }
    
    static func evaluate(m: CommandMode) -> Result<InstallOptions, CommandantError<MASError>> {
        return curry(InstallOptions.create)
            <*> m <| Argument(usage: "app ID(s) to install")
            <*> m <| Switch(flag: nil, key: "force", usage: "force reinstall")
    }
}
