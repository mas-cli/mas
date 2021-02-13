/// A Nimble matcher that succeeds when the exepected sequence is a prefix of the actual sequence.
///
/// This is a matcher abstraction for https://developer.apple.com/documentation/swift/sequence/2854218-starts
public func beginWith<Seq1: Sequence, Seq2: Sequence>(prefix expectedPrefix: Seq2?)
    -> Predicate<Seq1> where Seq1.Element: Equatable, Seq1.Element == Seq2.Element {
    return Predicate.define("begin with <\(stringify(expectedPrefix))>") { (actualExpression, msg) in
        let actualPrefix = try actualExpression.evaluate()
        switch (expectedPrefix, actualPrefix) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (nil, nil), (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case (let expected?, let actual?):
            let matches = actual.starts(with: expected)
            return PredicateResult(bool: matches, message: msg)
        }
    }
}

/// A Nimble matcher that succeeds when the expected sequence is the prefix of the actual sequence, using the given predicate as the equivalence test.
///
/// This is a matcher abstraction for https://developer.apple.com/documentation/swift/sequence/2996828-starts
public func beginWith<Seq1: Sequence, Seq2: Sequence>(
    prefix expectedPrefix: Seq2?,
    by areEquivalent: @escaping (Seq1.Element, Seq2.Element) -> Bool
) -> Predicate<Seq1> {
    return Predicate.define("begin with <\(stringify(expectedPrefix))>") { (actualExpression, msg) in
        let actualPrefix = try actualExpression.evaluate()
        switch (expectedPrefix, actualPrefix) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (nil, nil), (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case (let expected?, let actual?):
            let matches = actual.starts(with: expected, by: areEquivalent)
            return PredicateResult(bool: matches, message: msg)
        }
    }
}
