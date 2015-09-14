//
//  Outdated.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

struct OutdatedCommand: CommandType {
    let verb = "outdated"
    let function = "Lists pending updates from the Mac App Store"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            let updateController = CKUpdateController.sharedUpdateController()
            let updates = updateController.availableUpdates() as! [CKUpdate]
            for update in updates {
                print("\(update.itemIdentifier) \(update.title) \(update.actionParams)")
            }
        default:
            break
        }
        return .Success(())
    }
}