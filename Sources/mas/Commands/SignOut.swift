//
//  SignOut.swift
//  mas
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import CommerceKit

extension Mas {
    struct SignOut: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "signout",
            abstract: "Sign out of the Mac App Store"
        )

        /// Runs the command.
        func run() throws {
            if #available(macOS 10.13, *) {
                ISServiceProxy.genericShared().accountService.signOut()
            } else {
                // Using CKAccountStore to sign out does nothing on High Sierra
                // https://github.com/mas-cli/mas/issues/129
                CKAccountStore.shared().signOut()
            }
        }
    }
}
