//
// ProcessInfo.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import Darwin
private import Foundation

extension ProcessInfo {
	var sudoUID: uid_t? {
		environment["SUDO_UID"].flatMap { uid_t($0) }
	}

	var sudoGID: gid_t? {
		environment["SUDO_GID"].flatMap { gid_t($0) }
	}
}
