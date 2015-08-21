//
//  ListUpdates.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

struct ListUpdatesCommand: CommandType {
    let verb = "list-updates"
    let function = "Lists pending updates from the Mac App Store"
    
    func run(mode: CommandMode) -> Result<(), CommandantError<MASError>> {
        switch mode {
        case .Arguments:
            let updateController = CKUpdateController.sharedUpdateController()
            print(updateController.availableUpdates())
        default:
            break
        }
        return .success(())
    }
}