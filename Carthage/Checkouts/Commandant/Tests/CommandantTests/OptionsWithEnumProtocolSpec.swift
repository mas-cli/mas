//
//  OptionsWithEnumProtocolSpec.swift
//  Commandant
//
//  Created by Vitalii Budnik on 11/22/17.
//  Copyright © 2017 Carthage. All rights reserved.
//

@testable import Commandant
import Foundation
import Nimble
import Quick
import Result

class OptionsWithEnumProtocolSpec: QuickSpec {
	override func spec() {
		describe("CommandMode.Arguments") {
			func tryArguments(_ arguments: String...) -> Result<TestEnumOptions, CommandantError<NoError>> {
				return TestEnumOptions.evaluate(.arguments(ArgumentParser(arguments)))
			}
			
			it("should fail if a required argument is missing") {
				expect(tryArguments().value).to(beNil())
			}

			it("should fail if an option is missing a value") {
				expect(tryArguments("required", "--strictIntValue").value).to(beNil())
			}

			it("should fail if an option is missing a value") {
				expect(tryArguments("required", "--strictStringValue", "drop").value).to(beNil())
			}
			
			it("should fail if an optional strict int parameter is wrong") {
				expect(tryArguments("required", "256").value).to(beNil())
			}
			
			it("should succeed without optional string arguments") {
				let value = tryArguments("required").value
				let expected = TestEnumOptions(strictIntValue: .theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything, strictStringValue: .foobar, strictStringsArray: [], optionalStrictStringsArray: nil, optionalStrictStringValue: nil, optionalStrictInt: .min, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should succeed without optional strict int value") {
				let value = tryArguments("required", "5").value
				let expected = TestEnumOptions(strictIntValue: .theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything, strictStringValue: .foobar, strictStringsArray: [], optionalStrictStringsArray: nil, optionalStrictStringValue: nil, optionalStrictInt: .giveFive, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should succeed with some strings array arguments separated by comma") {
				let value = tryArguments("required", "--strictIntValue", "3", "--optionalStrictStringValue", "baz", "255", "--strictStringsArray", "a,b,c").value
				let expected = TestEnumOptions(strictIntValue: .three, strictStringValue: .foobar, strictStringsArray: [.a, .b, .c], optionalStrictStringsArray: nil, optionalStrictStringValue: .baz, optionalStrictInt: .max, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should succeed with some strings array arguments separated by space") {
				let value = tryArguments("required", "--strictIntValue", "3", "--optionalStrictStringValue", "baz", "--strictStringsArray", "a b c", "255").value
				let expected = TestEnumOptions(strictIntValue: .three, strictStringValue: .foobar, strictStringsArray: [.a, .b, .c], optionalStrictStringsArray: nil, optionalStrictStringValue: .baz, optionalStrictInt: .max, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should succeed with some strings array arguments separated by comma and space") {
				let value = tryArguments("required", "--strictIntValue", "3", "--optionalStrictStringValue", "baz", "--strictStringsArray", "a, b, c", "255").value
				let expected = TestEnumOptions(strictIntValue: .three, strictStringValue: .foobar, strictStringsArray: [.a, .b, .c], optionalStrictStringsArray: nil, optionalStrictStringValue: .baz, optionalStrictInt: .max, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should succeed with some optional string arguments") {
				let value = tryArguments("required", "--strictIntValue", "3", "--optionalStrictStringValue", "baz", "255").value
				let expected = TestEnumOptions(strictIntValue: .three, strictStringValue: .foobar, strictStringsArray: [], optionalStrictStringsArray: nil, optionalStrictStringValue: .baz, optionalStrictInt: .max, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should succeed without optional array arguments") {
				let value = tryArguments("required").value
				let expected = TestEnumOptions(strictIntValue: .theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything, strictStringValue: .foobar, strictStringsArray: [], optionalStrictStringsArray: nil, optionalStrictStringValue: nil, optionalStrictInt: .min, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should succeed with some optional array arguments") {
				let value = tryArguments("required", "--strictIntValue", "3", "--optionalStrictStringsArray", "one, two", "255").value
				let expected = TestEnumOptions(strictIntValue: .three, strictStringValue: .foobar, strictStringsArray: [], optionalStrictStringsArray: [.one, .two], optionalStrictStringValue: nil, optionalStrictInt: .max, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should override previous optional arguments") {
				let value = tryArguments("required", "--strictIntValue", "3", "--strictStringValue", "fuzzbuzz", "--strictIntValue", "5", "--strictStringValue", "bazbuzz").value
				let expected = TestEnumOptions(strictIntValue: .giveFive, strictStringValue: .bazbuzz, strictStringsArray: [], optionalStrictStringsArray: nil, optionalStrictStringValue: nil, optionalStrictInt: .min, requiredName: "required", arguments: [])
				expect(value).to(equal(expected))
			}
			
			it("should consume the rest of positional arguments") {
				let value = tryArguments("required", "255", "value1", "value2").value
				let expected = TestEnumOptions(strictIntValue: .theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything, strictStringValue: .foobar, strictStringsArray: [], optionalStrictStringsArray: nil, optionalStrictStringValue: nil, optionalStrictInt: .max, requiredName: "required", arguments: [ "value1", "value2" ])
				expect(value).to(equal(expected))
			}
			
			it("should treat -- as the end of valued options") {
				let value = tryArguments("--", "--strictIntValue").value
				let expected = TestEnumOptions(strictIntValue: .theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything, strictStringValue: .foobar, strictStringsArray: [], optionalStrictStringsArray: nil, optionalStrictStringValue: nil, optionalStrictInt: .min, requiredName: "--strictIntValue", arguments: [])
				expect(value).to(equal(expected))
			}
		}
		
		describe("CommandMode.Usage") {
			it("should return an error containing usage information") {
				let error = TestEnumOptions.evaluate(.usage).error
				expect(error?.description).to(contain("strictIntValue"))
				expect(error?.description).to(contain("strictStringValue"))
				expect(error?.description).to(contain("name you're required to"))
				expect(error?.description).to(contain("optionally specify"))
			}
		}
	}
}

struct TestEnumOptions: OptionsProtocol, Equatable {
	let strictIntValue: StrictIntValue
	let strictStringValue: StrictStringValue
	let strictStringsArray: [StrictStringValue]
	let optionalStrictStringsArray: [StrictStringValue]?
	let optionalStrictStringValue: StrictStringValue?
	let optionalStrictInt: StrictIntValue
	let requiredName: String
	let arguments: [String]
	
	typealias ClientError = NoError
	
	static func create(_ a: StrictIntValue) -> (StrictStringValue) -> ([StrictStringValue]) -> ([StrictStringValue]?) -> (StrictStringValue?) -> (String) -> (StrictIntValue) -> ([String]) -> TestEnumOptions {
		return { b in { c in { d in { e in { f in { g in { h in
			return self.init(strictIntValue: a, strictStringValue: b, strictStringsArray: c, optionalStrictStringsArray: d, optionalStrictStringValue: e, optionalStrictInt: g, requiredName: f, arguments: h)
			} } } } } } }
	}
	
	static func evaluate(_ m: CommandMode) -> Result<TestEnumOptions, CommandantError<NoError>> {
		return create
			<*> m <| Option(key: "strictIntValue", defaultValue: .theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything, usage: "`0` - zero, `255` - max, `3` - three, `5` - five or `42` - The Answer")
			<*> m <| Option(key: "strictStringValue", defaultValue: .foobar, usage: "`foobar`, `bazbuzzz`, `a`, `b`, `c`, `one`, `two`, `c`")
			<*> m <| Option<[StrictStringValue]>(key: "strictStringsArray", defaultValue: [], usage: "Some array of arguments")
			<*> m <| Option<[StrictStringValue]?>(key: "optionalStrictStringsArray", defaultValue: nil, usage: "Some array of arguments")
			<*> m <| Option<StrictStringValue?>(key: "optionalStrictStringValue", defaultValue: nil, usage: "Some string value")
			<*> m <| Argument(usage: "A name you're required to specify")
			<*> m <| Argument(defaultValue: .min, usage: "A number that you can optionally specify")
			<*> m <| Argument(defaultValue: [], usage: "An argument list that consumes the rest of positional arguments")
	}
}

func ==(lhs: TestEnumOptions, rhs: TestEnumOptions) -> Bool {
	return lhs.strictIntValue == rhs.strictIntValue && lhs.strictStringValue == rhs.strictStringValue && lhs.strictStringsArray == rhs.strictStringsArray && lhs.optionalStrictStringsArray == rhs.optionalStrictStringsArray && lhs.optionalStrictStringValue == rhs.optionalStrictStringValue && lhs.optionalStrictInt == rhs.optionalStrictInt && lhs.requiredName == rhs.requiredName && lhs.arguments == rhs.arguments
}

extension TestEnumOptions: CustomStringConvertible {
	var description: String {
		return "{ strictIntValue: \(strictIntValue), strictStringValue: \(strictStringValue), strictStringsArray: \(strictStringsArray), optionalStrictStringsArray: \(String(describing: optionalStrictStringsArray)), optionalStrictStringValue: \(String(describing: optionalStrictStringValue)), optionalStrictInt: \(optionalStrictInt), requiredName: \(requiredName), arguments: \(arguments) }"
	}
}

enum StrictStringValue: String, ArgumentProtocol {
	static var name: String = "Strict string value: `foobar`, `bazbuzz`, `one`, `two`, `baz`, `a`, `b` or `c`"
	
	case foobar
	case bazbuzz
	case one
	case two
	case baz
	case a
	case b
	case c
}

enum StrictIntValue: UInt8, ArgumentProtocol {
	static var name: String = "Strict int value: `3`, `5`, `42`, `0`, `255`"
	
	case min = 0
	case three = 3
	case giveFive = 5
	case theAnswerToTheUltimateQuestionOfLifeTheUniverseAndEverything = 42
	case max = 255
}
