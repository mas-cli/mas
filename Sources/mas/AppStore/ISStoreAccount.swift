//
// ISStoreAccount.swift
// mas
//
// Created by Andrew Naylor on 2015-08-22.
// Copyright © 2015 Andrew Naylor. All rights reserved.
//

import CommerceKit

extension ISStoreAccount: @unchecked Sendable {
	@MainActor // swiftlint:disable:next attributes
	static var primaryAccount: ISStoreAccount {
		get async {
			await withCheckedContinuation { continuation in
				ISServiceProxy.genericShared().accountService.primaryAccount { continuation.resume(returning: $0) }
			}
		}
	}
}
