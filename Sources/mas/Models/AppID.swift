//
// AppID.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

typealias AppID = UInt64

extension AppID {
	var notInstalledMessage: String {
		"No installed apps with app ID \(self)"
	}
}
