//
//  Upgrade.swift
//  mas-cli
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

struct UpgradeCommand: CommandType {
    typealias Options = UpgradeOptions
    let verb = "upgrade"
    let function = "Upgrade outdated apps from the Mac App Store"
    
    func run(options: Options) -> Result<(), MASError> {
        let updateController = CKUpdateController.sharedUpdateController()
        
        guard let pendingUpdates = updateController.availableUpdates() else {
            return .Failure(MASError(code: .NoUpdatesFound))
        }
        
        let updates: [CKUpdate]
        if let appIds = options.appIds where appIds.count > 0 {
            updates = pendingUpdates.filter {
                appIds.contains($0.itemIdentifier.unsignedLongLongValue)
            }
        } else {
            // Upgrade everything
            guard pendingUpdates.count > 0 else {
                print("Everything is up-to-date")
                return .Success(())
            }
            updates = pendingUpdates
        }
        
        print("Upgrading \(updates.count) outdated application\(updates.count > 1 ? "s" : ""):")
        print(updates.map({ "\($0.title) (\($0.bundleVersion))" }).joinWithSeparator(", "))
        
        let updateResults = updates.flatMap {
            download($0.itemIdentifier.unsignedLongLongValue)
        }

        switch updateResults.count {
        case 0:
            return .Success()
        case 1:
            return .Failure(updateResults[0])
        default:
            return .Failure(MASError(code: .DownloadFailed))
        }
    }
}

struct UpgradeOptions: OptionsType {
    let appIds: [UInt64]?
    
    static func create(appIds: [Int]) -> UpgradeOptions {
        return UpgradeOptions(appIds: appIds.map { UInt64($0) })
    }
    
    static func evaluate(m: CommandMode) -> Result<UpgradeOptions, CommandantError<MASError>> {
        return create
            <*> m <| Argument(usage: "app ID(s) to install")
    }
}