//
// UserAndGroup.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import Darwin

func run<T>(asEffectiveUID uid: uid_t, andEffectiveGID gid: gid_t, _ body: () throws -> T) throws -> T {
	let originalEffectiveUID = geteuid()
	let originalEffectiveGID = getegid()
	guard originalEffectiveUID == 0 else {
		try set(effectiveUID: uid)
		defer {
			reset(effectiveUID: originalEffectiveUID)
		}
		try set(effectiveGID: gid)
		defer {
			reset(effectiveGID: originalEffectiveGID)
		}
		return try body()
	}

	try set(effectiveGID: gid)
	defer {
		reset(effectiveGID: originalEffectiveGID)
	}
	try set(effectiveUID: uid)
	defer {
		reset(effectiveUID: originalEffectiveUID)
	}
	return try body()
}

func run<T>(asEffectiveUID uid: uid_t, andEffectiveGID gid: gid_t, _ body: () async throws -> T) async throws -> T {
	let originalEffectiveUID = geteuid()
	let originalEffectiveGID = getegid()
	guard originalEffectiveUID == 0 else {
		try set(effectiveUID: uid)
		defer {
			reset(effectiveUID: originalEffectiveUID)
		}
		try set(effectiveGID: gid)
		defer {
			reset(effectiveGID: originalEffectiveGID)
		}
		return try await body()
	}

	try set(effectiveGID: gid)
	defer {
		reset(effectiveGID: originalEffectiveGID)
	}
	try set(effectiveUID: uid)
	defer {
		reset(effectiveUID: originalEffectiveUID)
	}
	return try await body()
}
