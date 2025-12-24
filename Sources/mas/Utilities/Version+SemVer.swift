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

	// periphery:ignore
	init?(from versionString: String)
}

protocol CoreIntegerVersion: Version {
	associatedtype Integer: BinaryInteger

	var coreIntegers: [Integer] { get }
}

extension CoreIntegerVersion where Integer: FixedWidthInteger {
	var coreElements: [String] {
		coreIntegers.map { String($0) }
	}
}

// periphery:ignore
protocol MajorMinorPatch { // swiftlint:disable unused_declaration
	var major: String { get }
	var minor: String { get }
	var patch: String { get } // swiftlint:enable unused_declaration
}

protocol MajorMinorPatchInteger: MajorMinorPatch {
	associatedtype Integer: BinaryInteger

	var majorInteger: Integer { get }
	var minorInteger: Integer { get }
	var patchInteger: Integer { get }
}

extension MajorMinorPatchInteger {
	var major: String {
		"\(majorInteger)"
	}

	var minor: String {
		"\(minorInteger)"
	}

	var patch: String {
		"\(patchInteger)"
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

protocol SemVer: CoreIntegerVersion, SemVerSyntax, MajorMinorPatchInteger {}

extension SemVer where Integer: FixedWidthInteger {
	static func parse(_ versionString: String, defaultCoreElement: Integer? = nil) // swiftformat:disable:next indent
	throws -> (major: Integer, minor: Integer, patch: Integer, prereleaseElements: [String], buildElements: [String]) {
		guard
			let match = unsafe versionString.wholeMatch(of: semVerRegex),
			let major = Integer(String(match.1)) ?? defaultCoreElement,
			let minor = Integer(String(match.2)) ?? defaultCoreElement,
			let patch = Integer(String(match.3)) ?? defaultCoreElement
		else {
			throw MASError.error("Failed to parse SemVer from \(versionString)")
		}

		return (major, minor, patch, match.4.elements, match.5.elements)
	}
}

struct SemVerInt: SemVer {
	typealias Integer = Int

	let majorInteger: Integer
	let minorInteger: Integer
	let patchInteger: Integer
	var coreIntegers: [Integer]
	let prereleaseElements: [String]
	let buildElements: [String]

	init(
		major: Integer = 0,
		minor: Integer = 0,
		patch: Integer = 0,
		prereleaseElements: [String] = [],
		buildElements: [String] = [],
	) {
		majorInteger = major
		minorInteger = minor
		patchInteger = patch
		coreIntegers = [major, minor, patch]
		self.prereleaseElements = prereleaseElements
		self.buildElements = buildElements
	}

	init?(from versionString: String) {
		do {
			let semVer = try Self.parse(versionString)
			self.init(
				major: semVer.major,
				minor: semVer.minor,
				patch: semVer.patch,
				prereleaseElements: semVer.prereleaseElements,
				buildElements: semVer.buildElements,
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
		let match = unsafe versionString.wholeMatch(of: universalSemVerRegex)! // swiftlint:disable:this force_unwrapping
		coreElements = match.1.elements
		prereleaseElements = match.2.elements
		buildElements = match.3.elements
	}
}

private extension BigInt {
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
		let selfInteger = BigInt(self)
		let thatInteger = BigInt(that)
		return selfInteger.map { thatInteger.map($0.compare(to:)) ?? .orderedAscending }
		?? thatInteger.map { _ in .orderedDescending } // swiftformat:disable:this indent
		?? compare(that, options: mask, range: range, locale: locale) // swiftformat:disable:this indent
	}
}

private extension [String] {
	func compareSemVerElements(to that: Self) -> ComparisonResult {
		zip(self, that).first { $0 != $1 }.map { $0.compareSemVerElement(to: $1) } ?? (count.compare(to: that.count))
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

private nonisolated(unsafe) let semVerRegex =
	/(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?/
private nonisolated(unsafe) let universalSemVerRegex = /([^-+]*+)?+(?:-([^+]*+))?+(?:\+(.*+))?+/
