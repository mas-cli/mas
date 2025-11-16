//
// Group.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import Darwin

func groupName(for gid: gid_t) -> String? {
	String(validatingCString: getgrgid(gid).pointee.gr_name)
}

func set(effectiveGID gid: gid_t) throws {
	guard setegid(gid) == 0 else {
		throw MASError.runtimeError(
			"Failed to switch effective group from \(getegid().nameAndID) to \(gid.nameAndID)"
		)
	}
}

func reset(effectiveGID gid: gid_t) {
	do {
		try set(effectiveGID: gid)
	} catch {
		MAS.printer.warning(error: error)
	}
}

func requireWheelGroup(withErrorMessageSuffix errorMessageSuffix: String? = nil) throws {
	guard getgid() == 0 else {
		throw MASError.runtimeError("The effective group must be wheel\(errorMessageSuffix.map { " \($0)" } ?? "").")
	}
}

private extension gid_t {
	var nameAndID: String {
		"\(groupName(for: self).quoted) (\(self))"
	}
}
