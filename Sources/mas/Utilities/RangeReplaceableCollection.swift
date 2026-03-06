//
// RangeReplaceableCollection.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

extension RangeReplaceableCollection {
	func padding(toCount minimumCount: Int, with padValue: Element) -> Self {
		let appendCount = minimumCount - count
		return appendCount > 0 ? self + repeatElement(padValue, count: appendCount) : self
	}
}
