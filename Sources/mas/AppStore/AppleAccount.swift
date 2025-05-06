//
// AppleAccount.swift
// mas
//
// Created by Ross Goldberg on 2025-05-06.
// Copyright © 2025 mas-cli. All rights reserved.
//

private import CommerceKit
internal import Foundation

struct AppleAccount: Sendable {
	let emailAddress: String
	// swiftlint:disable:next legacy_objc_type
	let dsID: NSNumber
}

@MainActor // swiftlint:disable:next attributes
var appleAccount: AppleAccount {
	get async throws {
		if #available(macOS 12, *) {
			// Account information is no longer available on macOS 12+.
			// https://github.com/mas-cli/mas/issues/417
			throw MASError.notSupported
		}
		return await withCheckedContinuation { continuation in
			ISServiceProxy.genericShared().accountService.primaryAccount { account in
				continuation.resume(returning: AppleAccount(emailAddress: account.identifier, dsID: account.dsID))
			}
		}
	}
}
