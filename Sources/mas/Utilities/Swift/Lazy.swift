//
// Lazy.swift
// mas
//
// Copyright © 2026 mas-cli. All rights reserved.
//

private import os

final class Lazy<Value: Sendable>: Sendable {
	private struct Storage {
		var value = Value?.none
		var initializer = (@Sendable () -> Value)?.none
	}

	private let state: OSAllocatedUnfairLock<Storage>

	var value: Value {
		state.withLock { storage in
			storage.value ?? {
				storage.value = storage.initializer!() // swiftlint:disable:this force_unwrapping
				storage.initializer = nil
				return storage.value! // swiftlint:disable:this force_unwrapping
			}()
		}
	}

	init(_ initializer: @escaping @Sendable () -> Value) {
		state = .init(initialState: Storage(value: nil, initializer: initializer))
	}

	convenience init(_ initializer: @autoclosure @escaping @Sendable () -> Value) {
		self.init(initializer)
	}

	deinit {
		// Empty
	}
}
