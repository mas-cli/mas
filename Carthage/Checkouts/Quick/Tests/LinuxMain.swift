import XCTest
import Quick

@testable import QuickTests

Quick.QCKMain([
    AfterSuiteTests.self,
    Configuration_AfterEachSpec.self,
    Configuration_BeforeEachSpec.self,
    CurrentSpecTests.self,
    FunctionalTests_AfterEachSpec.self,
    FunctionalTests_BeforeEachSpec.self,
    FunctionalTests_BeforeSuite_BeforeSuiteSpec.self,
    FunctionalTests_BeforeSuite_Spec.self,
    FunctionalTests_ItSpec.self,
    FunctionalTests_PendingSpec.self,
    FunctionalTests_CrossReferencingSpecA.self,
    FunctionalTests_CrossReferencingSpecB.self,
    FunctionalTests_SharedExamples_BeforeEachSpec.self,
    FunctionalTests_SharedExamples_ContextSpec.self,
    FunctionalTests_SharedExamples_Spec.self,
    FunctionalTests_SubclassSpec.self,
    FunctionalTests_SubclassOfSubclassWithStructPropertySpec.self,
    _FunctionalTests_FocusedSpec_Focused.self,
    _FunctionalTests_FocusedSpec_Unfocused.self
],
configurations: [
    FunctionalTests_Configuration_AfterEach.self,
    FunctionalTests_Configuration_BeforeEach.self,
    FunctionalTests_FocusedSpec_SharedExamplesConfiguration.self,
    FunctionalTests_SharedExamples_BeforeEachTests_SharedExamples.self,
    FunctionalTests_SharedExamplesTests_SharedExamples.self
],
testCases: [
    testCase(AfterEachTests.allTests),
    testCase(BeforeEachTests.allTests),
    testCase(BeforeSuiteTests.allTests),
    testCase(Configuration_AfterEachTests.allTests),
    testCase(Configuration_BeforeEachTests.allTests),
    // testCase(DescribeTests.allTests),
    testCase(FocusedTests.allTests),
    testCase(FunctionalTests_CrossReferencingSpecA.allTests),
    testCase(FunctionalTests_CrossReferencingSpecB.allTests),
    testCase(ItTests.allTests),
    testCase(PendingTests.allTests),
    testCase(SharedExamples_BeforeEachTests.allTests),
    testCase(SharedExamplesTests.allTests)
])
