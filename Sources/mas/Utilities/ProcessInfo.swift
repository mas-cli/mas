//
//  ProcessInfo.swift
//  mas
//
//  Created by Ross Goldberg on 2024-10-29.
//  Copyright © 2024 mas-cli. All rights reserved.
//

import Foundation

extension ProcessInfo {
    var sudoUsername: String? {
        environment["SUDO_USER"]
    }

    var sudoUID: uid_t? {
        if let uid = environment["SUDO_UID"] {
            uid_t(uid)
        } else {
            nil
        }
    }

    var sudoGID: gid_t? {
        if let gid = environment["SUDO_GID"] {
            gid_t(gid)
        } else {
            nil
        }
    }
}
