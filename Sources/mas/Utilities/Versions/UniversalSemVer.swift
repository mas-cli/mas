//
// UniversalSemVer.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import BigInt
internal import Foundation

struct UniversalSemVer: SemVerSyntax {
	let coreElements: [String]
	let prereleaseElements: [String]
	let buildElements: [String]
	let rawValue: String

	init(rawValue: String) {
		guard let match = rawValue.wholeMatch(of: universalSemVerRegex) else {
			preconditionFailure("Failed to match regex \(universalSemVerRegex)")
		}

		coreElements = match.1.elements
		prereleaseElements = match.2.elements
		buildElements = match.3.elements
		self.rawValue = rawValue
	}
}

private extension BigUInt {
	func compare(to that: Self) -> ComparisonResult {
		self < that ? .orderedAscending : self == that ? .orderedSame : .orderedDescending
	}
}

private extension FixedWidthInteger {
	func compare(to that: Self) -> ComparisonResult {
		self < that ? .orderedAscending : self == that ? .orderedSame : .orderedDescending
	}
}

private extension String {
	func compareSemVerElement(
		to that: Self,
		options mask: CompareOptions = .init(),
		range: Range<Self.Index>? = nil,
		locale: Locale? = nil,
	) -> ComparisonResult {
		let thatInteger = BigUInt(that)
		return BigUInt(self).map { thatInteger.map($0.compare(to:)) ?? .orderedAscending }
		?? thatInteger.map { _ in .orderedDescending } // swiftformat:disable:this indent
		?? compare(that, options: mask, range: range, locale: locale) // swiftformat:disable:this indent
	}
}

private extension [String] {
	func compareSemVerElements(to that: Self) -> ComparisonResult {
		zip(self, that).first { $0 != $1 }.map { $0.compareSemVerElement(to: $1) }
		?? dropLast { $0 == "0" }.count.compare(to: that.dropLast { $0 == "0" }.count) // swiftformat:disable:this indent
	}
}

extension Substring? {
	var elements: [String] {
		map { $0.split(separator: ".") }?.map(String.init(_:)) ?? .init()
	}
}

extension Version {
	func compareSemVer(to that: Self) -> ComparisonResult {
		let coreComparison = coreElements.compareSemVerElements(to: that.coreElements)
		return coreComparison == .orderedSame
		? prereleaseElements.compareSemVerElements(to: that.prereleaseElements) // swiftformat:disable:this indent
		: coreComparison
	}

	func compareSemVerAndBuild(to that: Self) -> ComparisonResult {
		let semVerComparison = compareSemVer(to: that)
		return semVerComparison == .orderedSame
		? buildElements.compareSemVerElements(to: that.buildElements) // swiftformat:disable:this indent
		: semVerComparison
	}
}

let universalSemVerRegex = /([^-+]*+)?+(?:-([^+]*+))?+(?:\+(.*+))?+/
