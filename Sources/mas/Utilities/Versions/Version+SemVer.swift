//
// Version+SemVer.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import BigInt
internal import Foundation

// swiftlint:disable:next blanket_disable_command
// swiftlint:disable file_types_order one_declaration_per_file

protocol Version: CustomStringConvertible {
	var coreElements: [String] { get }
	var prereleaseElements: [String] { get }
	var buildElements: [String] { get }

	var core: String { get }
	var prerelease: String? { get }
	var build: String? { get }

	init?(from versionString: String) // periphery:ignore
}

protocol CoreIntegerVersion: Version {
	associatedtype Integer: BinaryInteger

	var coreIntegers: [Integer] { get }
}

extension CoreIntegerVersion where Integer: FixedWidthInteger {
	var coreElements: [String] {
		coreIntegers.map { .init($0) }
	}
}

protocol MajorMinorPatch { // swiftlint:disable unused_declaration
	var major: String { get } // periphery:ignore
	var minor: String { get } // periphery:ignore
	var patch: String { get } // periphery:ignore
} // swiftlint:enable unused_declaration

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

protocol SemVerSyntax: Version {}

extension SemVerSyntax {
	var core: String {
		coreElements.joined(separator: ".")
	}

	var prerelease: String? {
		prereleaseElements.isEmpty ? nil : prereleaseElements.joined(separator: ".")
	}

	var build: String? {
		buildElements.isEmpty ? nil : buildElements.joined(separator: ".")
	}

	var description: String {
		"\(core)\(prerelease.map { "-\($0)" } ?? "")\(build.map { "+\($0)" } ?? "")"
	}
}

protocol SemVerSyntaxInteger: CoreIntegerVersion, SemVerSyntax, MajorMinorPatchInteger {}

struct UniversalSemVerInt: SemVerSyntaxInteger {
	typealias Integer = Int

	let coreIntegers: [Integer]
	let prereleaseElements: [String]
	let buildElements: [String]

	var majorInteger: Integer {
		coreIntegers[0]
	}

	var minorInteger: Integer {
		coreIntegers[1]
	}

	var patchInteger: Integer {
		coreIntegers[2]
	}

	init(
		coreIntegers: [Integer],
		prereleaseElements: [String] = [],
		buildElements: [String] = [],
	) {
		self.coreIntegers = coreIntegers.padding(toCount: 3, with: 0)
		self.prereleaseElements = prereleaseElements
		self.buildElements = buildElements
	}

	init?(from versionString: String) {
		do {
			let match = versionString.wholeMatch(of: unsafe universalSemVerRegex)! // swiftlint:disable:this force_unwrapping
			self = .init(
				coreIntegers: try match.1.elements.map { coreElement in
					guard let coreInteger = Integer(coreElement) else {
						throw MASError.error(coreElement)
					}

					return coreInteger
				},
				prereleaseElements: match.2.elements,
				buildElements: match.3.elements,
			)
		} catch {
			return nil
		}
	}
}

struct UniversalSemVer: SemVerSyntax {
	let coreElements: [String]
	let prereleaseElements: [String]
	let buildElements: [String]

	init(from versionString: String) {
		let match = versionString.wholeMatch(of: unsafe universalSemVerRegex)! // swiftlint:disable:this force_unwrapping
		coreElements = match.1.elements
		prereleaseElements = match.2.elements
		buildElements = match.3.elements
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
		options mask: CompareOptions = [],
		range: Range<Self.Index>? = nil,
		locale: Locale? = nil,
	) -> ComparisonResult {
		let selfInteger = BigUInt(self)
		let thatInteger = BigUInt(that)
		return selfInteger.map { thatInteger.map($0.compare(to:)) ?? .orderedAscending }
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

private extension Substring? {
	var elements: [String] {
		map { $0.split(separator: ".") }?.map(String.init(_:)) ?? []
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

private nonisolated(unsafe) let universalSemVerRegex = /([^-+]*+)?+(?:-([^+]*+))?+(?:\+(.*+))?+/
