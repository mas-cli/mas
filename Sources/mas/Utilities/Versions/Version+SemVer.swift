//
// Version+SemVer.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

protocol Version: RawRepresentable<String> {
	var coreElements: [String] { get }
	var prereleaseElements: [String] { get }
	var buildElements: [String] { get } // swiftlint:disable unused_declaration

	var core: String { get } // periphery:ignore
	var prerelease: String? { get } // periphery:ignore
	var build: String? { get } // periphery:ignore
} // swiftlint:enable unused_declaration
