//
//  Outdated.swift
//  mas-cli
//
//  Created by Andrew Naylor on 21/08/2015.
//  Copyright (c) 2015 Andrew Naylor. All rights reserved.
//

import Commandant
import Result
import CommerceKit

struct OutdatedCommand: CommandProtocol {
    typealias Options = NoOptions<MASError>
    let verb = "outdated"
    let function = "Lists pending updates from the Mac App Store"
    
    func run(_ options: Options) -> Result<(), MASError> {
        let updateController = CKUpdateController.shared()
        let updates = updateController?.availableUpdates()
        let softwareMap = CKSoftwareMap.shared()
        for update in updates! {
            if let installed = softwareMap.product(forBundleIdentifier: update.bundleID) {
                print("\(update.itemIdentifier) \(update.title) (\(installed.bundleVersion) -> \(update.bundleVersion))")
            } else {
                print("\(update.itemIdentifier) \(update.title) (unknown -> \(update.bundleVersion))")
            }
        }
        return .success(())
    }
}
