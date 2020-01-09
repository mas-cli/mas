import Quick
import Nimble

// This is a functional test ensuring that no crash occurs when a spec class
// references another spec class during its spec setup.

class FunctionalTests_CrossReferencingSpecA: QuickSpec {
    override func spec() {
        _ = FunctionalTests_CrossReferencingSpecB()
        it("does not crash") {}
    }
}

class FunctionalTests_CrossReferencingSpecB: QuickSpec {
    override func spec() {
        _ = FunctionalTests_CrossReferencingSpecA()
        it("does not crash") {}
    }
}
