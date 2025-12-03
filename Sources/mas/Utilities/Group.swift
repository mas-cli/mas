//
// Group.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import Darwin

private extension gid_t {
	var nameAndID: String {
		"\(String(cString: getgrgid(self).pointee.gr_name).quoted) (\(self))"
	}
}

func set(effectiveGID gid: gid_t) throws {
	guard setegid(gid) == 0 else {
		throw MASError.error("Failed to switch effective group from \(getegid().nameAndID) to \(gid.nameAndID)")
	}
}

func reset(effectiveGID gid: gid_t) {
	do {
		try set(effectiveGID: gid)
	} catch {
		MAS.printer.warning(error: error)
	}
}
