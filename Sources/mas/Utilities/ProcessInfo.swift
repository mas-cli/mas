//
// ProcessInfo.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import Darwin
private import Foundation

extension ProcessInfo {
	var sudoUserName: String? {
		environment["SUDO_USER"]
	}

	var sudoGroupName: String? {
		sudoGID.flatMap { String(validatingCString: getgrgid($0).pointee.gr_name) }
	}

	var sudoUID: uid_t? {
		environment["SUDO_UID"].flatMap { uid_t($0) }
	}

	var sudoGID: gid_t? {
		environment["SUDO_GID"].flatMap { gid_t($0) }
	}
}
