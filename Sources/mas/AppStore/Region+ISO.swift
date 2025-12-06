//
// Region+ISO.swift
// mas
//
// Copyright © 2024 mas-cli. All rights reserved.
//

private import Foundation

typealias Region = String

var region: Region {
	if #available(macOS 13, *) {
		Locale.current.region?.identifier ?? "US"
	} else {
		Locale.current.regionCode ?? "US"
	}
}
