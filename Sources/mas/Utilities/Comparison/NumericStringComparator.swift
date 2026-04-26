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

	var order: SortOrder {
		get {
			self == .forward ? .forward : .reverse
		}
		set {
			self = newValue == .forward ? .forward : .reverse
		}
	}

	func compare(_ lhs: String, _ rhs: String) -> ComparisonResult {
		let result = lhs.compare(rhs, options: .numeric)
		return self == .forward ? result : result.reversed
	}
}

extension ComparisonResult {
	var reversed: Self {
		switch self {
		case .orderedAscending:
			.orderedDescending
		case .orderedDescending:
			.orderedAscending
		case .orderedSame:
			.orderedSame
		}
	}
}
