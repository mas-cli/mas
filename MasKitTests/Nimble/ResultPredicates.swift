//
//  ResultPreticates.swift
//  MasKitTests
//
//  Created by Ben Chatelain on 12/27/18.
//  Copyright © 2018 mas-cli. All rights reserved.
//

@testable import MasKit
import Result
import Nimble

/// Nimble predicate for result enum success case, no associated value
func beSuccess() -> Predicate<Result<(), MASError>> {
    return Predicate.define("be <success>") { expression, message in
        if let actual = try expression.evaluate(),
            case .success = actual {
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}

/// Nimble predicate for result enum failure with associated error
func beFailure(test: @escaping (MASError) -> Void = { _ in }) -> Predicate<Result<(), MASError>> {
    return Predicate.define("be <failure>") { expression, message in
        if let actual = try expression.evaluate(),
            case let .failure(error) = actual {
            test(error)
            return PredicateResult(status: .matches, message: message)
        }
        return PredicateResult(status: .fail, message: message)
    }
}
