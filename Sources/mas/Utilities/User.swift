//
// User.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import Darwin

func set(effectiveUID uid: uid_t) throws {
	guard seteuid(uid) == 0 else {
		throw MASError.runtimeError("Failed to switch effective user from \(geteuid().nameAndID) to \(uid.nameAndID)")
	}
}

func reset(effectiveUID uid: uid_t) {
	do {
		try set(effectiveUID: uid)
	} catch {
		MAS.printer.warning(error: error)
	}
}

func requireRootUser(withErrorMessageSuffix errorMessageSuffix: String? = nil) throws {
	guard getuid() == 0 else {
		throw MASError.runtimeError("The user must be root\(errorMessageSuffix.map { " \($0)" } ?? "").")
	}
}

private extension uid_t {
	var nameAndID: String {
		"\(String(cString: getpwuid(self).pointee.pw_name).quoted) (\(self))"
	}
}
