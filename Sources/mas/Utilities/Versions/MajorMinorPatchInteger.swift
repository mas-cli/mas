//
// MajorMinorPatchInteger.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

protocol MajorMinorPatchInteger: MajorMinorPatch {
	associatedtype Integer: BinaryInteger

	var majorInteger: Integer { get }
	var minorInteger: Integer { get }
	var patchInteger: Integer { get }
}

extension MajorMinorPatchInteger {
	var major: String {
		.init(majorInteger)
	}

	var minor: String {
		.init(minorInteger)
	}

	var patch: String {
		.init(patchInteger)
	}
}
