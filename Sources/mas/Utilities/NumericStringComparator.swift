//
// NumericStringComparator.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import Foundation

enum NumericStringComparator: SortComparator {
	case forward
	case reverse

	typealias Compared = String

	var order: SortOrder {
		get {
			self == .forward ? .forward : .reverse
		}
		set {
			self = newValue == .forward ? .forward : .reverse
		}
	}

	func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
		switch lhs.compare(rhs, options: .numeric) {
		case .orderedAscending:
			order == .forward ? .orderedAscending : .orderedDescending
		case .orderedDescending:
			order == .forward ? .orderedDescending : .orderedAscending
		case .orderedSame:
			.orderedSame
		}
	}
}
