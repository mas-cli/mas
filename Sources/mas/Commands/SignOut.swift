//
//  SignOut.swift
//  mas
//
//  Created by Andrew Naylor on 14/02/2016.
//  Copyright © 2016 Andrew Naylor. All rights reserved.
//

import Commandant
import CommerceKit

public struct SignOutCommand: CommandProtocol {
    public typealias Options = NoOptions<MASError>
    public let verb = "signout"
    public let function = "Sign out of the Mac App Store"

    /// Runs the command.
    public func run(_: Options) -> Result<Void, MASError> {
        if #available(macOS 10.13, *) {
            ISServiceProxy.genericShared().accountService.signOut()
        } else {
            // Using CKAccountStore to sign out does nothing on High Sierra
            // https://github.com/mas-cli/mas/issues/129
            CKAccountStore.shared().signOut()
        }

        return .success(())
    }
}
