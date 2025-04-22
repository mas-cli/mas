// Don't include generated header comments

// MARK: Types and naming

/// Types begin with a capital letter.
struct User {
    let name: String

    /// if the first letter of an acronym is lowercase, the entire thing should
    /// be lowercase.
    let json: Any

    /// if the first letter of an acronym is uppercase, the entire thing should
    /// be uppercase.
    static func decode(from json: JSON) -> Self {
        Self(json: json)
    }
}

/// Use () for void arguments and Void for void return types.
let closure: () -> Void = {
    // Do nothing
}

/// When using classes, default to marking them as final.
final class MyClass {
    // Empty class
}

/// Use typealias when closures are referenced in multiple places.
typealias CoolClosure = (Int) -> Bool

/// Use aliased parameter names when function parameters are ambiguous.
func yTown(some: Int, withCallback callback: CoolClosure) -> Bool {
    callback(some)
}

/// It's OK to use $ variable references if the closure is very short and
/// readability is maintained.
let cool = yTown(5) { $0 == 6 }

/// Use full variable names when closures are more complex.
let cool = yTown(5) { foo in
    max(foo, 0)
    // …
}

// Strongify weak references in async closures
APIClient.getAwesomeness { [weak self] result in
    guard let self else {
        return
    }
    self.stopLoadingSpinner()
    self.show(result)
}

/// Use if-let to check for not `nil` (even if using an implicitly unwrapped variable from an API).
func someUnauditedAPI(thing: String?) {
    if let thing {
        print(thing)
    }
}

/// When the type is known you can let the compiler infer.
let response: Response = .success(NSData())

func doSomeWork() -> Response {
    let data = Data("", .utf8)
    return .success(data)
}

switch response {
case .success(let data):
    print("The response returned successfully", data)
case .failure(let error):
    print("An error occurred:", error)
}

// MARK: Organization

/// Group methods into specific extensions for each level of access control.
private extension MyClass {
    func doSomethingPrivate() {
        // Do something
    }
}

// MARK: Breaking up long lines

// One expression to evaluate and short or no return
guard let singleTest = somethingFailable() else {
    return
}

guard statementThatShouldBeTrue else {
    return
}

// If a guard clause requires multiple lines, chop down, then start `else` new line
// In this case, always chop down else clause.
guard
    let oneItem = somethingFailable(),
    let secondItem = somethingFailable2()
else {
    return
}

// If the return in else is long, move to next line
guard let something = somethingFailable() else {
    return someFunctionThatDoesSomethingInManyWordsOrLines()
}
