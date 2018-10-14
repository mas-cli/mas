//
//  Upgrade.swift
//  mas-cli
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Result
import CommerceKit

struct UpgradeCommand: CommandProtocol {
    typealias Options = UpgradeOptions
    let verb = "upgrade"
    let function = "Upgrade outdated apps from the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
        let updateController = CKUpdateController.shared()
        
        let updates: [CKUpdate]
        let apps = options.apps
        if apps.count > 0 {
            let softwareMap = CKSoftwareMap.shared()

            // convert input into a list of appId's

            let appIds: [UInt64]

            appIds = apps.compactMap {
                if let appId = UInt64($0) {
                    return appId
                }
                if let appId = softwareMap.appIdWithProductName($0) {
                    return appId
                }
                return nil
            }

            // check each of those for updates

            updates = appIds.compactMap {
                updateController?.availableUpdate(withItemIdentifier: $0)
            }
            
            guard updates.count > 0 else {
                printWarning("Nothing found to upgrade")
                return .success(())
            }
        } else {
            updates = updateController?.availableUpdates() ?? []

            // Upgrade everything
            guard updates.count > 0 else {
                print("Everything is up-to-date")
                return .success(())
            }
        }
        
        print("Upgrading \(updates.count) outdated application\(updates.count > 1 ? "s" : ""):")
        print(updates.map({ "\($0.title) (\($0.bundleVersion))" }).joined(separator: ", "))
        
        let updateResults = updates.compactMap {
            download($0.itemIdentifier.uint64Value)
        }

        switch updateResults.count {
        case 0:
            return .success(())
        case 1:
            return .failure(updateResults[0])
        default:
            return .failure(.downloadFailed(error: nil))
        }
    }
}

struct UpgradeOptions: OptionsProtocol {
    let apps: [String]
    
    static func create(_ apps: [String]) -> UpgradeOptions {
        return UpgradeOptions(apps: apps)
    }
    
    static func evaluate(_ m: CommandMode) -> Result<UpgradeOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(defaultValue: [], usage: "app(s) to upgrade")
    }
}
