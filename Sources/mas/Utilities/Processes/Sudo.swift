//
// Sudo.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import ArgumentParser
private import Darwin
private import Foundation

func sudo(_ executableName: String, args: some Sequence<String>) throws {
	guard let executablePath = Bundle.main.executableURL?.filePath else {
		throw MASError.error("Failed to get the executable path for sudo \(executableName) \(args.joined(separator: " "))")
	}

	try sudo([executablePath] + args)
}

private func sudo(_ args: some Sequence<String>) throws {
	let cArgs = unsafe (["sudo", "MAS_NO_AUTO_INDEX=1"] + args).map { unsafe strdup($0) }
	defer {
		for unsafe cArg in unsafe cArgs {
			unsafe free(cArg)
		}
	}

	var pid = 0 as pid_t
	let spawnStatus = unsafe posix_spawn(&pid, "/usr/bin/sudo", nil, nil, cArgs + [nil], environ)
	guard spawnStatus == 0 else {
		throw MASError.error(
			"Failed to spawn installer process",
			error: unsafe String(cString: strerror(spawnStatus)),
			separator: ": ",
		)
	}

	var sudoStatus = 0 as Int32
	unsafe waitpid(pid, &sudoStatus, 0)
	guard sudoStatus == 0 else {
		throw ExitCode(max((sudoStatus >> 8) & 0xff, 1))
	}
}
