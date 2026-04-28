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

protocol Version: RawRepresentable<String> {
	var coreElements: [String] { get }
	var prereleaseElements: [String] { get }
	var buildElements: [String] { get } // swiftlint:disable unused_declaration

	var core: String { get } // periphery:ignore
	var prerelease: String? { get } // periphery:ignore
	var build: String? { get } // periphery:ignore
} // swiftlint:enable unused_declaration

protocol CoreIntegerVersion: Version {
	associatedtype Integer: BinaryInteger

	var coreIntegers: [Integer] { get }
}

extension CoreIntegerVersion where Integer: FixedWidthInteger {
	fileprivate static func coreElements(from coreIntegers: [Integer]) -> [String] {
		coreIntegers.map { .init($0) }
	}

	var coreElements: [String] {
		Self.coreElements(from: coreIntegers)
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
	fileprivate static func core(from coreElements: [String]) -> String {
		coreElements.joined(separator: ".")
	}

	fileprivate static func prerelease(from prereleaseElements: [String]) -> String? {
		prereleaseElements.isEmpty ? nil : prereleaseElements.joined(separator: ".")
	}

	fileprivate static func build(from buildElements: [String]) -> String? {
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

protocol SemVerSyntaxInteger: CoreIntegerVersion, SemVerSyntax, MajorMinorPatchInteger {}

struct UniversalSemVerInt: SemVerSyntaxInteger {
	let coreIntegers: [Int]
	let prereleaseElements: [String]
	let buildElements: [String]
	let rawValue: String

	var majorInteger: Int {
		coreIntegers[0]
	}

	var minorInteger: Int {
		coreIntegers[1]
	}

	var patchInteger: Int {
		coreIntegers[2]
	}

	init(
		coreIntegers: [Int],
		prereleaseElements: [String] = .init(),
		buildElements: [String] = .init(),
	) { // periphery:ignore
		self.init(
			coreIntegers: coreIntegers,
			prereleaseElements: prereleaseElements,
			buildElements: buildElements,
			rawValue: """
				\(Self.core(from: Self.coreElements(from: coreIntegers)))\
				\(Self.prerelease(from: prereleaseElements).map { "-\($0)" } ?? "")\
				\(Self.build(from: buildElements).map { "+\($0)" } ?? "")
				""",
		)
	}

	init?(rawValue: String) {
		do {
			let match = rawValue.wholeMatch(of: universalSemVerRegex)! // swiftlint:disable:this force_unwrapping
			self = .init(
				coreIntegers: try match.1.elements.map { coreElement in
					try .init(coreElement) ?? { throw MASError.error(coreElement) }()
				},
				prereleaseElements: match.2.elements,
				buildElements: match.3.elements,
				rawValue: rawValue,
			)
		} catch {
			return nil
		}
	}

	private init(
		coreIntegers: [Int],
		prereleaseElements: [String],
		buildElements: [String],
		rawValue: String,
	) {
		self.coreIntegers = coreIntegers.padding(toCount: 3, with: 0)
		self.prereleaseElements = prereleaseElements
		self.buildElements = buildElements
		self.rawValue = rawValue
	}
}

struct UniversalSemVer: SemVerSyntax {
	let coreElements: [String]
	let prereleaseElements: [String]
	let buildElements: [String]
	let rawValue: String

	init(rawValue: String) {
		let match = rawValue.wholeMatch(of: universalSemVerRegex)! // swiftlint:disable:this force_unwrapping
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

private extension Substring? {
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

private let universalSemVerRegex = /([^-+]*+)?+(?:-([^+]*+))?+(?:\+(.*+))?+/
