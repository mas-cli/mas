//
// SemVerSyntax.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

protocol SemVerSyntax: Version {}

extension SemVerSyntax {
	static func core(from coreElements: [String]) -> String {
		coreElements.joined(separator: ".")
	}

	static func prerelease(from prereleaseElements: [String]) -> String? {
		prereleaseElements.isEmpty ? nil : prereleaseElements.joined(separator: ".")
	}

	static func build(from buildElements: [String]) -> String? {
		buildElements.isEmpty ? nil : buildElements.joined(separator: ".")
	}

	var core: String {
		Self.core(from: coreElements)
	}

	var prerelease: String? {
		Self.prerelease(from: prereleaseElements)
	}

	var build: String? {
		Self.build(from: buildElements)
	}
}
