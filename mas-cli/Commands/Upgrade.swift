//
//  Upgrade.swift
//  mas-cli
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

struct UpgradeCommand: CommandProtocol {
    typealias Options = UpgradeOptions
    let verb = "upgrade"
    let function = "Upgrade outdated apps from the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
        let updateController = CKUpdateController.shared()
        
        let updates: [CKUpdate]
        let appIds = options.appIds
        if appIds.count > 0 {
            updates = appIds.flatMap { updateController?.availableUpdate(withItemIdentifier: $0) }
            
            guard updates.count > 0 else {
                warn("Nothing found to upgrade")
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
        
        let updateResults = updates.flatMap {
            download($0.itemIdentifier.uint64Value)
        }

        switch updateResults.count {
        case 0:
            return .success()
        case 1:
            return .failure(updateResults[0])
        default:
            return .failure(MASError(code: .downloadFailed))
        }
    }
}

struct UpgradeOptions: OptionsProtocol {
    let appIds: [UInt64]
    
    static func create(_ appIds: [Int]) -> UpgradeOptions {
        return UpgradeOptions(appIds: appIds.map { UInt64($0) })
    }
    
    static func evaluate(_ m: CommandMode) -> Result<UpgradeOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(defaultValue: [], usage: "app ID(s) to install")
    }
}
