import Foundation
import XCTest
import Nimble

final class EqualTest: XCTestCase, XCTestCaseProvider {
    func testEquality() {
        expect(1 as CInt).to(equal(1 as CInt))
        expect(1 as CInt).to(equal(1))
        expect(1).to(equal(1))
        expect("hello").to(equal("hello"))
        expect("hello").toNot(equal("world"))

        expect {
            1
        }.to(equal(1))

        failsWithErrorMessage("expected to equal <world>, got <hello>") {
            expect("hello").to(equal("world"))
        }
        failsWithErrorMessage("expected to not equal <hello>, got <hello>") {
            expect("hello").toNot(equal("hello"))
        }
    }

    func testArrayEquality() {
        expect([1, 2, 3]).to(equal([1, 2, 3]))
        expect([1, 2, 3]).toNot(equal([1, 2]))
        expect([1, 2, 3]).toNot(equal([1, 2, 4]))

        let array1: [Int] = [1, 2, 3]
        let array2: [Int] = [1, 2, 3]
        expect(array1).to(equal(array2))
        expect(array1).to(equal([1, 2, 3]))
        expect(array1).toNot(equal([1, 2] as [Int]))

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        expect(NSArray(array: [1, 2, 3])).to(equal(NSArray(array: [1, 2, 3])))
#endif

        failsWithErrorMessage("expected to equal <[1, 2]>, got <[1, 2, 3]>") {
            expect([1, 2, 3]).to(equal([1, 2]))
        }
    }

    func testSetEquality() {
        expect(Set([1, 2])).to(equal(Set([1, 2])))
        expect(Set<Int>()).to(equal(Set<Int>()))
        expect(Set<Int>()) == Set<Int>()
        expect(Set([1, 2])) != Set<Int>()

        failsWithErrorMessageForNil("expected to equal <[1, 2]>, got <nil>") {
            expect(nil as Set<Int>?).to(equal(Set([1, 2])))
        }

        failsWithErrorMessage("expected to equal <[1, 2, 3]>, got <[2, 3]>, missing <[1]>") {
            expect(Set([2, 3])).to(equal(Set([1, 2, 3])))
        }

        failsWithErrorMessage("expected to equal <[1, 2, 3]>, got <[1, 2, 3, 4]>, extra <[4]>") {
            expect(Set([1, 2, 3, 4])).to(equal(Set([1, 2, 3])))
        }

        failsWithErrorMessage("expected to equal <[1, 2, 3]>, got <[2, 3, 4]>, missing <[1]>, extra <[4]>") {
            expect(Set([2, 3, 4])).to(equal(Set([1, 2, 3])))
        }

        failsWithErrorMessage("expected to equal <[1, 2, 3]>, got <[2, 3, 4]>, missing <[1]>, extra <[4]>") {
            expect(Set([2, 3, 4])) == Set([1, 2, 3])
        }

        failsWithErrorMessage("expected to not equal <[1, 2, 3]>, got <[1, 2, 3]>") {
            expect(Set([1, 2, 3])) != Set([1, 2, 3])
        }
    }

    func testDoesNotMatchNils() {
        failsWithErrorMessageForNil("expected to equal <nil>, got <nil>") {
            expect(nil as String?).to(equal(nil as String?))
        }
        failsWithErrorMessageForNil("expected to not equal <nil>, got <foo>") {
            expect("foo").toNot(equal(nil as String?))
        }
        failsWithErrorMessageForNil("expected to not equal <bar>, got <nil>") {
            expect(nil as String?).toNot(equal("bar"))
        }

        failsWithErrorMessageForNil("expected to equal <nil>, got <nil>") {
            expect(nil as [Int]?).to(equal(nil as [Int]?))
        }
        failsWithErrorMessageForNil("expected to not equal <[1]>, got <nil>") {
            expect(nil as [Int]?).toNot(equal([1]))
        }
        failsWithErrorMessageForNil("expected to not equal <nil>, got <[1]>") {
            expect([1]).toNot(equal(nil as [Int]?))
        }

        failsWithErrorMessageForNil("expected to equal <nil>, got <nil>") {
            expect(nil as [Int: Int]?).to(equal(nil as [Int: Int]?))
        }
        failsWithErrorMessageForNil("expected to not equal <[1: 1]>, got <nil>") {
            expect(nil as [Int: Int]?).toNot(equal([1: 1]))
        }
        failsWithErrorMessageForNil("expected to not equal <nil>, got <[1: 1]>") {
            expect([1: 1]).toNot(equal(nil as [Int: Int]?))
        }

        failsWithErrorMessageForNil("expected to not equal <nil>, got <1>") {
            expect(1).toNot(equal(nil))
        }
    }

    func testDictionaryEquality() {
        expect(["foo": "bar"]).to(equal(["foo": "bar"]))
        expect(["foo": "bar"]).toNot(equal(["foo": "baz"]))

        let actual = ["foo": "bar"]
        let expected = ["foo": "bar"]
        let unexpected = ["foo": "baz"]
        expect(actual).to(equal(expected))
        expect(actual).toNot(equal(unexpected))

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
        expect(NSDictionary(object: "bar", forKey: "foo" as NSString)).to(equal(["foo": "bar"]))
        expect(NSDictionary(object: "bar", forKey: "foo" as NSString) as? [String: String]).to(equal(expected))
#endif
    }

    func testDataEquality() {
        let actual = "foobar".data(using: .utf8)
        let expected = "foobar".data(using: .utf8)
        let unexpected = "foobarfoo".data(using: .utf8)

        expect(actual).to(equal(expected))
        expect(actual).toNot(equal(unexpected))

        #if os(Linux)
            // swiftlint:disable:next todo
            // FIXME: Swift on Linux triggers a segfault when calling NSData's hash() (last checked on 03-11)
            let expectedErrorMessage = "expected to equal <Data<length=9>>, got <Data<length=6>>"
        #else
            let expectedErrorMessage = "expected to equal <Data<hash=92856895,length=9>>,"
                + " got <Data<hash=114710658,length=6>>"
        #endif

        failsWithErrorMessage(expectedErrorMessage) {
            expect(actual).to(equal(unexpected))
        }
    }

    func testNSObjectEquality() {
        expect(NSNumber(value: 1)).to(equal(NSNumber(value: 1)))
        expect(NSNumber(value: 1)) == NSNumber(value: 1)
        expect(NSNumber(value: 1)) != NSNumber(value: 2)
        expect { NSNumber(value: 1) }.to(equal(1))
    }

    func testOperatorEquality() {
        expect("foo") == "foo"
        expect("foo") != "bar"

        failsWithErrorMessage("expected to equal <world>, got <hello>") {
            expect("hello") == "world"
            return
        }
        failsWithErrorMessage("expected to not equal <hello>, got <hello>") {
            expect("hello") != "hello"
            return
        }
    }

    func testOperatorEqualityWithArrays() {
        let array1: [Int] = [1, 2, 3]
        let array2: [Int] = [1, 2, 3]
        let array3: [Int] = [1, 2]
        expect(array1) == array2
        expect(array1) != array3
    }

    func testOperatorEqualityWithDictionaries() {
        let dict1 = ["foo": "bar"]
        let dict2 = ["foo": "bar"]
        let dict3 = ["foo": "baz"]
        expect(dict1) == dict2
        expect(dict1) != dict3
    }

    func testOptionalEquality() {
        expect(1 as CInt?).to(equal(1))
        expect(1 as CInt?).to(equal(1 as CInt?))
    }

    func testArrayOfOptionalsEquality() {
        let array1: [Int?] = [1, nil, 3]
        let array2: [Int?] = [nil, 2, 3]
        let array3: [Int?] = [1, nil, 3]

        expect(array1).toNot(equal(array2))
        expect(array1).to(equal(array3))
        expect(array2).toNot(equal(array3))

        let allNils1: [String?] = [nil, nil, nil, nil]
        let allNils2: [String?] = [nil, nil, nil, nil]
        let notReallyAllNils: [String?] = [nil, nil, nil, "turtles"]

        expect(allNils1).to(equal(allNils2))
        expect(allNils1).toNot(equal(notReallyAllNils))

        let noNils1: [Int?] = [1, 2, 3, 4, 5]
        let noNils2: [Int?] = [1, 3, 5, 7, 9]

        expect(noNils1).toNot(equal(noNils2))

        failsWithErrorMessage("expected to equal <[Optional(1), nil]>, got <[nil, Optional(2)]>") {
            let arrayOfOptionalInts: [Int?] = [nil, 2]
            let anotherArrayOfOptionalInts: [Int?] = [1, nil]
            expect(arrayOfOptionalInts).to(equal(anotherArrayOfOptionalInts))
            return
        }
    }

    func testDictionariesWithDifferentSequences() {
        // see: https://github.com/Quick/Nimble/issues/61
        // these dictionaries generate different orderings of sequences.
        let result = ["how": 1, "think": 1, "didnt": 2, "because": 1,
            "interesting": 1, "always": 1, "right": 1, "such": 1,
            "to": 3, "say": 1, "cool": 1, "you": 1,
            "weather": 3, "be": 1, "went": 1, "was": 2,
            "sometimes": 1, "and": 3, "mind": 1, "rain": 1,
            "whole": 1, "everything": 1, "weather.": 1, "down": 1,
            "kind": 1, "mood.": 1, "it": 2, "everyday": 1, "might": 1,
            "more": 1, "have": 2, "person": 1, "could": 1, "tenth": 2,
            "night": 1, "write": 1, "Youd": 1, "affects": 1, "of": 3,
            "Who": 1, "us": 1, "an": 1, "I": 4, "my": 1, "much": 2,
            "wrong.": 1, "peacefully.": 1, "amazing": 3, "would": 4,
            "just": 1, "grade.": 1, "Its": 2, "The": 2, "had": 1, "that": 1,
            "the": 5, "best": 1, "but": 1, "essay": 1, "for": 1, "summer": 2,
            "your": 1, "grade": 1, "vary": 1, "pretty": 1, "at": 1, "rain.": 1,
            "about": 1, "allow": 1, "thought": 1, "in": 1, "sleep": 1, "a": 1,
            "hot": 1, "really": 1, "beach": 1, "life.": 1, "we": 1, "although": 1, ]

        let storyCount = ["The": 2, "summer": 2, "of": 3, "tenth": 2, "grade": 1,
            "was": 2, "the": 5, "best": 1, "my": 1, "life.": 1, "I": 4,
            "went": 1, "to": 3, "beach": 1, "everyday": 1, "and": 3,
            "we": 1, "had": 1, "amazing": 3, "weather.": 1, "weather": 3,
            "didnt": 2, "really": 1, "vary": 1, "much": 2, "always": 1,
            "pretty": 1, "hot": 1, "although": 1, "sometimes": 1, "at": 1,
            "night": 1, "it": 2, "would": 4, "rain.": 1, "mind": 1, "rain": 1,
            "because": 1, "cool": 1, "everything": 1, "down": 1, "allow": 1,
            "us": 1, "sleep": 1, "peacefully.": 1, "Its": 2, "how": 1,
            "affects": 1, "your": 1, "mood.": 1, "Who": 1, "have": 2,
            "thought": 1, "that": 1, "could": 1, "write": 1, "a": 1,
            "whole": 1, "essay": 1, "just": 1, "about": 1, "in": 1,
            "grade.": 1, "kind": 1, "right": 1, "Youd": 1, "think": 1,
            "for": 1, "such": 1, "an": 1, "interesting": 1, "person": 1,
            "might": 1, "more": 1, "say": 1, "but": 1, "you": 1, "be": 1, "wrong.": 1, ]

        expect(result).to(equal(storyCount))
    }
}
