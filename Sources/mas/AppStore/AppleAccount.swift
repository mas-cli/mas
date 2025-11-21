//
// AppleAccount.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

internal import Foundation
private import StoreFoundation

struct AppleAccount: Sendable {
	let emailAddress: String?
	let dsID: NSNumber? // swiftlint:disable:this legacy_objc_type
}

@MainActor
var appleAccount: AppleAccount {
	get async throws {
		if #available(macOS 12, *) {
			// Account information is no longer available on macOS 12+
			// https://github.com/mas-cli/mas/issues/417
			throw MASError.notSupported
		}
		return await withCheckedContinuation { continuation in
			ISServiceProxy.genericShared().accountService.primaryAccount { account in
				continuation.resume(returning: AppleAccount(emailAddress: account?.identifier, dsID: account?.dsID))
			}
		}
	}
}
