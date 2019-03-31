// Don't include generated header comments

// MARK: Types and naming

// Types begin with a capital letter
struct User {
    let name: String

    // if the first letter of an acronym is lowercase, the entire thing should
    // be lowercase
    let json: Any

    // if the first letter of an acronym is uppercase, the entire thing should
    // be uppercase
    static func decode(from json: JSON) -> User {
        return User(json: json)
    }
}

// Use () for void arguments and Void for void return types
let f: () -> Void = {}

// When using classes, default to marking them as final
final class MyViewController: UIViewController {
    // Prefer strong IBOutlet references
    @IBOutlet var button: UIButton!
}

// Use typealias when closures are referenced in multiple places
typealias CoolClosure = (Int) -> Bool

// Use aliased parameter names when function parameters are ambiguous
func yTown(some: Int, withCallback callback: CoolClosure) -> Bool {
    return callback(some)
}

// It's OK to use $ variable references if the closure is very short and
// readability is maintained
let cool = yTown(5) { $0 == 6 }

// Use full variable names when closures are more complex
let cool = yTown(5) { foo in
    if foo > 5, foo < 0 {
        return true
    } else {
        return false
    }
}

// Strongify weak references in async closures
APIClient.getAwesomeness { [weak self] result in
    guard let self = self else { return }
    self.stopLoadingSpinner()
    self.show(result)
}

// If the API you are using has implicit unwrapping you should still use if-let
func someUnauditedAPI(thing: String!) {
    if let string = thing {
        print(string)
    }
}

// When the type is known you can let the compiler infer
let response: Response = .success(NSData())

func doSomeWork() -> Response {
    let data = ...
    return .success(data)
}

switch response {
case let .success(data):
    print("The response returned successfully \(data)")

case let .failure(error):
    print("An error occured: \(error)")
}

// MARK: Organization

// Group methods into specific extensions for each level of access control
private extension MyClass {
    func doSomethingPrivate() {}
}

// MARK: Breaking up long lines

// One expression to evaluate and short or no return
guard let singleTest = somethingFailable() else { return }
guard statementThatShouldBeTrue else { return }

// If there is one long expression to guard or multiple expressions
// move else to next line
guard let oneItem = somethingFailable(),
    let secondItem = somethingFailable2()
else { return }

// If the return in else is long, move to next line
guard let something = somethingFailable() else {
    return someFunctionThatDoesSomethingInManyWordsOrLines()
}
