//
//  Install.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Result
import CommerceKit

struct InstallCommand: CommandProtocol {
    typealias Options = InstallOptions
    let verb = "install"
    let function = "Install from the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
        // Try to download applications with given identifiers and collect results
        let downloadResults = options.appIds.compactMap { (appId) -> MASError? in
            if let product = installedApp(appId) , !options.forceInstall {
                printWarning("\(product.appName) is already installed")
                return nil
            }
            
            return download(appId)
        }

        switch downloadResults.count {
        case 0:
            return .success(())
        case 1:
            return .failure(downloadResults[0])
        default:
            return .failure(.downloadFailed(error: nil))
        }
    }
    
    fileprivate func installedApp(_ appId: UInt64) -> CKSoftwareProduct? {
        let appId = NSNumber(value: appId)
        
        let softwareMap = CKSoftwareMap.shared()
        return softwareMap.allProducts()?.first { $0.itemIdentifier == appId }
    }
}

struct InstallOptions: OptionsProtocol {
    let appIds: [UInt64]
    let forceInstall: Bool
    
    static func create(_ appIds: [Int]) -> (_ forceInstall: Bool) -> InstallOptions {
        return { forceInstall in
            return InstallOptions(appIds: appIds.map{UInt64($0)}, forceInstall: forceInstall)
        }
    }
    
    static func evaluate(_ m: CommandMode) -> Result<InstallOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "app ID(s) to install")
            <*> m <| Switch(flag: nil, key: "force", usage: "force reinstall")
    }
}
