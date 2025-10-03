//
// AppIdentifying.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

protocol AppIdentifying {
	var adamID: ADAMID { get }
	var bundleID: String { get }
}

extension AppIdentifying {
	var id: AppID {
		bundleID.isEmpty
		? .adamID(adamID) // swiftformat:disable:this indent
		: .bundleID(bundleID)
	}
}
