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
			guard let transformedElement = try await transform(element) else {
				continue
			}

			transformedElements.append(transformedElement)
		}
		return transformedElements
	}
}

extension Array {
	func compactMap<T, E: Error>(
		attemptingTo attempting: String,
		_ transform: (Element) async throws(E) -> T?
	) async -> [T] {
		await compactMap(handlingErrors: { MAS.printer.error(failedTo, attempting, $0, error: $1) }, transform)
	}

	private func compactMap<T, E: Error>(
		handlingErrors errorHandler: (Element, E) async -> Void,
		_ transform: (Element) async throws(E) -> T?
	) async -> [T] {
		await compactMap(
			handlingErrors: { element, error in
				await errorHandler(element, error)
				return nil
			},
			transform
		)
	}

	private func compactMap<T, E: Error>(
		handlingErrors errorHandler: (Element, E) async -> T?,
		_ transform: (Element) async throws(E) -> T?
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

extension Array {
	func forEach<E: Error>(attemptTo actionText: String, _ body: (Element) async throws(E) -> Void) async {
		await forEach(handlingErrors: { MAS.printer.error(failedTo, actionText, $0, error: $1) }, body)
	}

	private func forEach<E: Error>(
		handlingErrors errorHandler: (Element, E) async -> Void,
		_ body: (Element) async throws(E) -> Void
	) async {
		for element in self {
			do {
				try await body(element)
			} catch {
				await errorHandler(element, error)
			}
		}
	}
}

private let failedTo = "Failed to"
