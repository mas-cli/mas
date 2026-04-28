//
// CoreIntegerVersion.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

protocol CoreIntegerVersion: Version {
	associatedtype Integer: BinaryInteger

	var coreIntegers: [Integer] { get }
}

extension CoreIntegerVersion where Integer: FixedWidthInteger {
	static func coreElements(from coreIntegers: [Integer]) -> [String] {
		coreIntegers.map { .init($0) }
	}

	var coreElements: [String] {
		Self.coreElements(from: coreIntegers)
	}
}
