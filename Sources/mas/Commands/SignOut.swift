//
//  SignOut.swift
//  mas
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import ArgumentParser
import CommerceKit

extension MAS {
    struct SignOut: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "signout",
            abstract: "Sign out of the Apple ID currently signed in in the Mac App Store"
        )

        /// Runs the command.
        func run() throws {
            ISServiceProxy.genericShared().accountService.signOut()
        }
    }
}
