//
//  Upgrade.swift
//  mas-cli
//
//  Created by Andrew Naylor on 30/12/2015.
//  Copyright © 2015 Andrew Naylor. All rights reserved.
//

struct UpgradeCommand: CommandType {
    let verb = "upgrade"
    let function = "Performs all pending updates from the Mac App Store"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            let updateController = CKUpdateController.sharedUpdateController()
            
            guard let updates = updateController.availableUpdates() where updates.count > 0 else {
                print("Everything is up-to-date")
                break
            }
            
            print("Upgrading \(updates.count) outdated application\(updates.count > 1 ? "s" : ""):")
            print(updates.map({ "\($0.title) (\($0.bundleVersion))" }).joinWithSeparator(", "))
            for update in updates {
                if let error = download(UInt64(update.itemIdentifier.intValue)) {
                    return .Failure(CommandantError.CommandError(error))
                }
            }
        default:
            break
        }
        return .Success(())
    }
}