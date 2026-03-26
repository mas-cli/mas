//
// String.swift
// mas
//
// Copyright © 2025 mas-cli. All rights reserved.
//

private import Foundation

extension String {
	var quoted: Self {
		"'\(replacing("'", with: "\\'"))'"
	}

	func removingSuffix(_ suffix: Self) -> Self {
		hasSuffix(suffix) ? Self(dropLast(suffix.count)) : self
	}

	func similarity(to other: Self) -> Double {
		let this = Array(precomposedStringWithCanonicalMapping)
		let that = Array(other.precomposedStringWithCanonicalMapping)
		let thisLength = this.count
		let thatLength = that.count
		guard thisLength > 0 || thatLength > 0 else {
			return 1.0
		}
		guard thisLength != 0, thatLength != 0 else {
			return 0.0
		}

		// 2D matrix for Damerau-Levenshtein to track transpositions
		var matrix = Array(repeating: Array(repeating: 0.0, count: thatLength + 1), count: thisLength + 1)

		// Initialize base costs (deletions/insertions)
		for index in 0...thisLength {
			matrix[index][0] = Double(index)
		}
		for index in 0...thatLength {
			matrix[0][index] = Double(index)
		}

		for i in 1...thisLength { // swiftlint:disable:this identifier_name
			for j in 1...thatLength { // swiftlint:disable:this identifier_name
				let thisChar = this[i - 1]
				let thatChar = that[j - 1]
				if thisChar == thatChar {
					matrix[i][j] = matrix[i - 1][j - 1]
				} else {
					// Standard edit costs
					let cost = Swift.min(
						matrix[i - 1][j] + thisChar.structuralCost, // Deletion
						matrix[i][j - 1] + thatChar.structuralCost, // Insertion
						matrix[i - 1][j - 1] + thisChar.substitutionCost(for: thatChar),
					)

					matrix[i][j] = i > 1 && j > 1 && this[i - 1] == that[j - 2] && this[i - 2] == that[j - 1] // Transposition
					? Swift.min(cost, matrix[i - 2][j - 2] + 0.4) // swiftformat:disable:this indent
					: cost
				}
			}
		}

		return max(0, 1.0 - (matrix[thisLength][thatLength] / Double(max(thisLength, thatLength))))
	}
}

private extension Character {
	var structuralCost: Double {
		isWhitespace || isPunctuation || isSymbol ? 0.25 : 1.0
	}

	func substitutionCost(for char: Character) -> Double {
		String(self).folding(options: .diacriticInsensitive, locale: .current)
		== String(char).folding(options: .diacriticInsensitive, locale: .current) // swiftformat:disable:this indent
		? 0.1 // swiftformat:disable:this indent
		: lowercased() == char.lowercased() ? 0.2 : 1.0
	}
}
