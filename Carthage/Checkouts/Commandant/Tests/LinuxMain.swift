import XCTest
import Quick

@testable import CommandantTests

Quick.QCKMain([
	CommandWrapperSpec.self,
	OptionsProtocolSpec.self,
	OptionsWithEnumProtocolSpec.self,
	OrderedSetSpec.self,
])
