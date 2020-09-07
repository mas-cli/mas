/// A Nimble matcher that succeeds when the actual sequence and the exepected sequence contain the same elements in
/// the same order.
///
/// This is a matcher abstraction for https://developer.apple.com/documentation/swift/sequence/2854213-elementsequal
public func elementsEqual<Seq1: Sequence, Seq2: Sequence>(
    _ expectedValue: Seq2?
) -> Predicate<Seq1> where Seq1.Element: Equatable, Seq1.Element == Seq2.Element {
    return Predicate.define("elementsEqual <\(stringify(expectedValue))>") { (actualExpression, msg) in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (nil, nil), (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case (let expected?, let actual?):
            let matches = expected.elementsEqual(actual)
            return PredicateResult(bool: matches, message: msg)
        }
    }
}

/// A Nimble matcher that succeeds when the actual sequence and the exepected sequence contain equivalent elements in
/// the same order, using the given predicate as the equivalence test.
///
/// This is a matcher abstraction for https://developer.apple.com/documentation/swift/sequence/2949668-elementsequal
public func elementsEqual<Seq1: Sequence, Seq2: Sequence>(
    _ expectedValue: Seq2?,
    by areEquivalent: @escaping (Seq1.Element, Seq2.Element) -> Bool
) -> Predicate<Seq1> {
    return Predicate.define("elementsEqual <\(stringify(expectedValue))>") { (actualExpression, msg) in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: msg.appendedBeNilHint())
        case (nil, nil), (_, nil):
            return PredicateResult(status: .fail, message: msg)
        case (let expected?, let actual?):
            let matches = actual.elementsEqual(expected, by: areEquivalent)
            return PredicateResult(bool: matches, message: msg)
        }
    }
}
