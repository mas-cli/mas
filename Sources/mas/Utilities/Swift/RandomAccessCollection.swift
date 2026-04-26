//
// RandomAccessCollection.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

internal import Foundation

extension RandomAccessCollection {
	func lowerBound(of element: Element, using comparator: some SortComparator<Element>) -> Index {
		var low = startIndex
		var high = endIndex
		while low < high {
			let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
			if comparator.compare(self[mid], element) == .orderedAscending {
				low = index(after: mid)
			} else {
				high = mid
			}
		}
		return low
	}
}
