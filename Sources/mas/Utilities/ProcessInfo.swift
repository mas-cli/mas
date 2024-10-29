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
        guard let uid = environment["SUDO_UID"] else {
            return nil
        }
        return uid_t(uid)
    }

    var sudoGID: gid_t? {
        guard let gid = environment["SUDO_GID"] else {
            return nil
        }
        return gid_t(gid)
    }
}
