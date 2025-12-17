//
// MASTests+IgnoreEntry.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation
@testable private import mas
internal import Testing

private extension MASTests {
	@Test
	func createsEntryWithVersion() {
		let entry = IgnoreEntry(adamID: 12345, version: "1.0")
		#expect(entry.adamID == 12345)
		#expect(entry.version == "1.0")
	}

	@Test
	func createsEntryWithoutVersion() {
		let entry = IgnoreEntry(adamID: 67890, version: nil)
		#expect(entry.adamID == 67890)
		#expect(entry.version == nil)
	}

	@Test
	func matchesExactVersion() {
		let entry = IgnoreEntry(adamID: 12345, version: "2.0")

		// Should match exact version
		#expect(entry.matches(adamID: 12345, version: "2.0") == true)

		// Should not match different version
		#expect(entry.matches(adamID: 12345, version: "3.0") == false)

		// Should not match different adamID
		#expect(entry.matches(adamID: 67890, version: "2.0") == false)
	}

	@Test
	func matchesAllVersionsWithNilVersion() {
		let entry = IgnoreEntry(adamID: 12345, version: nil)

		// Should match any version
		#expect(entry.matches(adamID: 12345, version: "1.0") == true)
		#expect(entry.matches(adamID: 12345, version: "2.0") == true)
		#expect(entry.matches(adamID: 12345, version: "99.99") == true)

		// Should not match different adamID
		#expect(entry.matches(adamID: 67890, version: "1.0") == false)
	}

	@Test
	func encodesToJSON() throws {
		let entry = IgnoreEntry(adamID: 12345, version: "1.0")
		let encoder = JSONEncoder()
		let data = try encoder.encode(entry)
		let json = String(data: data, encoding: .utf8)!

		#expect(json.contains("12345"))
		#expect(json.contains("1.0"))
	}

	@Test
	func decodesFromJSON() throws {
		let json = """
			{"adamID":12345,"version":"1.0"}
			"""
		let decoder = JSONDecoder()
		let entry = try decoder.decode(IgnoreEntry.self, from: Data(json.utf8))

		#expect(entry.adamID == 12345)
		#expect(entry.version == "1.0")
	}

	@Test
	func encodesAndDecodesWithoutVersion() throws {
		let entry = IgnoreEntry(adamID: 67890, version: nil)
		let encoder = JSONEncoder()
		let data = try encoder.encode(entry)

		let decoder = JSONDecoder()
		let decoded = try decoder.decode(IgnoreEntry.self, from: data)

		#expect(decoded.adamID == 67890)
		#expect(decoded.version == nil)
	}

	@Test
	func implementsHashable() {
		let entry1 = IgnoreEntry(adamID: 12345, version: "1.0")
		let entry2 = IgnoreEntry(adamID: 12345, version: "1.0")
		let entry3 = IgnoreEntry(adamID: 12345, version: "2.0")

		// Same entries should be equal and have same hash
		#expect(entry1 == entry2)
		#expect(entry1.hashValue == entry2.hashValue)

		// Different entries should not be equal
		#expect(entry1 != entry3)
	}

	@Test
	func worksInSet() {
		var set = Set<IgnoreEntry>()
		let entry1 = IgnoreEntry(adamID: 12345, version: "1.0")
		let entry2 = IgnoreEntry(adamID: 12345, version: "1.0")
		let entry3 = IgnoreEntry(adamID: 12345, version: "2.0")

		set.insert(entry1)
		set.insert(entry2) // Duplicate, should not be added
		set.insert(entry3)

		#expect(set.count == 2)
		#expect(set.contains(entry1) == true)
		#expect(set.contains(entry3) == true)
	}
}
