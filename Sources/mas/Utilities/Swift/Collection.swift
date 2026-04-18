//
// Collection.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

extension Collection {
	func dropLast(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
		try indices.reversed().first { try !predicate(self[$0]) }.map { self[...$0] } ?? self[endIndex...]
	}
}

extension Collection where Element: Sendable {
	func concurrentMap<T: Sendable>(
		maxConcurrentTaskCount: Int = defaultMaxConcurrentTaskCount,
		_ transform: @escaping @Sendable (Element) async -> T,
	) async -> [T] {
		await concurrentTransform(maxConcurrentTaskCount: maxConcurrentTaskCount, transform)
	}

	func concurrentMap<T: Sendable>( // swiftlint:disable:this unused_declaration
		maxConcurrentTaskCount: Int = defaultMaxConcurrentTaskCount,
		_ transform: @escaping @Sendable (Element) async throws -> T,
	) async rethrows -> [T] { // periphery:ignore
		try await concurrentTransform(maxConcurrentTaskCount: maxConcurrentTaskCount, transform)
	}

	func concurrentCompactMap<T: Sendable>(
		maxConcurrentTaskCount: Int = defaultMaxConcurrentTaskCount,
		_ transform: @escaping @Sendable (Element) async -> T?,
	) async -> [T] {
		await concurrentCompactTransform(maxConcurrentTaskCount: maxConcurrentTaskCount, transform)
	}

	func concurrentCompactMap<T: Sendable>( // swiftlint:disable:this unused_declaration
		maxConcurrentTaskCount: Int = defaultMaxConcurrentTaskCount,
		_ transform: @escaping @Sendable (Element) async throws -> T?,
	) async rethrows -> [T] { // periphery:ignore
		try await concurrentCompactTransform(maxConcurrentTaskCount: maxConcurrentTaskCount, transform)
	}

	func concurrentCompactMap<T: Sendable>(
		attemptingTo perform: String,
		maxConcurrentTaskCount: Int = defaultMaxConcurrentTaskCount,
		_ transform: @escaping @Sendable (Element) async throws -> T?,
	) async -> [T] {
		await concurrentCompactMap(maxConcurrentTaskCount: maxConcurrentTaskCount) { element in
			do {
				return try await transform(element)
			} catch {
				MAS.printer.error(error is MASError ? [] : ["Failed to", perform, element], error: error)
				return nil
			}
		}
	}

	private func concurrentTransform<T: Sendable>(
		maxConcurrentTaskCount: Int,
		_ transform: @escaping @Sendable (Element) async throws -> T,
	) async rethrows -> [T] {
		try await withThrowingTaskGroup(of: (index: Int, result: T).self) { group in
			var iterator = enumerated().makeIterator()
			func addNextTask() {
				if let next = iterator.next() {
					group.addTask { (next.offset, try await transform(next.element)) }
				}
			}

			for _ in 0..<Swift.min(count, maxConcurrentTaskCount) {
				addNextTask()
			}

			return try await group.reduce(into: [T?](repeating: nil, count: count)) { results, indexedResult in
				results[indexedResult.index] = .some(indexedResult.result)
				addNextTask()
			}
			.map { $0! } // swiftlint:disable:this force_unwrapping
		}
	}

	private func concurrentCompactTransform<T: Sendable>(
		maxConcurrentTaskCount: Int,
		_ transform: @escaping @Sendable (Element) async throws -> T?,
	) async rethrows -> [T] {
		try await withThrowingTaskGroup(of: (index: Int, result: T?).self) { group in
			var iterator = enumerated().makeIterator()
			func addNextTask() {
				if let next = iterator.next() {
					group.addTask { (next.offset, try await transform(next.element)) }
				}
			}

			for _ in 0..<Swift.min(count, maxConcurrentTaskCount) {
				addNextTask()
			}

			return try await group.reduce(into: [T?](repeating: nil, count: count)) { results, indexedResult in
				results[indexedResult.index] = indexedResult.result
				addNextTask()
			}
			.compactMap(\.self)
		}
	}
}

private let defaultMaxConcurrentTaskCount = 16
