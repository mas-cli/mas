//
// ProcessInfo.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import Foundation

extension ProcessInfo {
	var sudoUserName: String? {
		environment["SUDO_USER"]
	}

	var sudoGroupName: String? {
		guard
			let sudoGID,
			let group = getgrgid(sudoGID)
		else {
			return nil
		}

		return String(validatingCString: group.pointee.gr_name)
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
