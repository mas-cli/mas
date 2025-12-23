//
// NSTextCheckingResult.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation

extension NSTextCheckingResult {
	func captureGroupMatch(number captureGroupNumber: Int, in string: String) -> String.SubSequence? {
		let range = range(at: captureGroupNumber)
		return range.location == NSNotFound ? nil : Range(range, in: string).map { string[$0] }
	}
}
