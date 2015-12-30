//
//  Outdated.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

struct OutdatedCommand: CommandType {
    typealias Options = NoOptions<MASError>
    let verb = "outdated"
    let function = "Lists pending updates from the Mac App Store"
    
    func run(options: Options) -> Result<(), MASError> {
        let updateController = CKUpdateController.sharedUpdateController()
        let updates = updateController.availableUpdates()
        for update in updates {
            print("\(update.itemIdentifier) \(update.title) (\(update.bundleVersion))")
        }
        return .Success(())
    }
}