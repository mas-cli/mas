//
//  ResultPreticates.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

import Nimble

@testable import MasKit

/// Nimble predicate for result enum success case, no associated value
func beSuccess() -> Predicate<Result<Void, MASError>> {
    Predicate.define("be <success>") { expression, message in
        if case .success = try expression.evaluate() {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

/// Nimble predicate for result enum failure with associated error
func beFailure(test: @escaping (MASError) -> Void = { _ in }) -> Predicate<Result<Void, MASError>> {
    Predicate.define("be <failure>") { expression, message in
        if case let .failure(error) = try expression.evaluate() {
            test(error)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}
