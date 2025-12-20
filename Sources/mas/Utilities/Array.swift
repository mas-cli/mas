//
// Array.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

extension Array {
	func compactMap<T, E: Error>(_ transform: (Element) async throws(E) -> T?) async throws(E) -> [T] {
		var transformedElements = [T]()
		transformedElements.reserveCapacity(count)
		return try await compactMap(into: &transformedElements, transform)
	}

	private func compactMap<T, E: Error>(
		into transformedElements: inout [T],
		_ transform: (Element) async throws(E) -> T?
	) async throws(E) -> [T] {
		for element in self {
			try await transform(element).map { transformedElements.append($0) }
		}
		return transformedElements
	}
}

extension Array {
	func compactMap<T, E: Error>(
		attemptingTo effect: String,
		_ transform: (Element) async throws(E) -> T?
	) async -> [T] {
		await compactMap(transform) { MAS.printer.error($1 is MASError ? [] : ["Failed to", effect, $0], error: $1) }
	}

	private func compactMap<T, E: Error>(
		_ transform: (Element) async throws(E) -> T?,
		handlingErrors errorHandler: (Element, E) async -> Void
	) async -> [T] {
		await compactMap(transform) { element, error in
			await errorHandler(element, error)
			return nil
		}
	}

	private func compactMap<T, E: Error>(
		_ transform: (Element) async throws(E) -> T?,
		handlingErrors errorHandler: (Element, E) async -> T?
	) async -> [T] {
		await compactMap { (element: Element) async -> T? in
			do {
				return try await transform(element)
			} catch let error as E {
				return await errorHandler(element, error)
			} catch {
				fatalError(
					"""
					Impossible error type \(type(of: error)) for element:
					\(element)

					Error:
					\(error)

					"""
				)
			}
		}
	}
}
