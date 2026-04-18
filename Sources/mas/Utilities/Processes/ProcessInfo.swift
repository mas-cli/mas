//
// ProcessInfo.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

internal import Darwin
private import Foundation

extension ProcessInfo {
	var sudoUID: uid_t {
		get throws {
			try environment["SUDO_UID"].flatMap(uid_t.init) ?? { throw MASError.error("Failed to get sudo uid") }()
		}
	}

	var sudoGID: gid_t {
		get throws {
			try environment["SUDO_GID"].flatMap(gid_t.init) ?? { throw MASError.error("Failed to get sudo gid") }()
		}
	}

	func runAsSudoEffectiveUserAndSudoEffectiveGroup<T>(_ body: () throws -> T) throws -> T {
		try run(asEffectiveUID: sudoUID, andEffectiveGID: sudoGID, body)
	}

	func runAsSudoEffectiveUserAndSudoEffectiveGroup<T>(_ body: () async throws -> T) async throws -> T {
		try await run(asEffectiveUID: sudoUID, andEffectiveGID: sudoGID, body)
	}

	func runAsSudoEffectiveUserAndSudoEffectiveGroupIfRootEffectiveUser<T>(_ body: () throws -> T) throws -> T {
		geteuid() == 0 ? try runAsSudoEffectiveUserAndSudoEffectiveGroup(body) : try body()
	}

	func runAsSudoEffectiveUserAndSudoEffectiveGroupIfRootEffectiveUser<T>(_ body: () async throws -> T)
	async throws -> T { // swiftformat:disable:this indent
		geteuid() == 0 ? try await runAsSudoEffectiveUserAndSudoEffectiveGroup(body) : try await body()
	}
}
