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
	guard let executablePath = Bundle.main.executableURL?.path(percentEncoded: false) else {
		throw MASError.error("Failed to get the executable path for sudo \(executableName) \(args.joined(separator: " "))")
	}

	try sudo([executablePath] + args)
}

private func sudo(_ args: some Sequence<String>) throws {
	let cArgs = (["sudo"] + args).map { strdup($0) }
	defer {
		for cArg in cArgs {
			free(cArg)
		}
	}

	var pid = 0 as pid_t
	let spawnStatus = posix_spawn(&pid, "/usr/bin/sudo", nil, nil, cArgs + [nil], environ)
	guard spawnStatus == 0 else {
		throw MASError.error(
			"Failed to spawn installer process",
			error: String(cString: strerror(spawnStatus)),
			separator: ": "
		)
	}

	var sudoStatus = 0 as Int32
	waitpid(pid, &sudoStatus, 0)
	guard sudoStatus == 0 else {
		throw ExitCode(max((sudoStatus >> 8) & 0xff, 1))
	}
}
