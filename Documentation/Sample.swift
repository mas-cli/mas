// Don't include generated header comments.

// MARK: Types & naming

/// The first letter of a type should be uppercase.
/// Prefer structs. When a class is necessary, default to making it `final`.
final class Sample {
	let name: String

	/// If the first letter of an acronym is lowercase, the entire thing should
	/// be lowercase.
	let json: Any

	deinit {
		// Clean up resources
	}

	/// If the first letter of an acronym is uppercase, the entire thing should
	/// be uppercase.
	static func decode(from json: JSON) -> Self {
		Self(json: json)
	}
}

/// Use `()` for void arguments & `Void` for void return types.
let closure: () -> Void = {
	// Do nothing
}

/// Use `typealias` when closures are referenced in multiple places.
typealias CoolClosure = (Int) -> Bool

/// Use aliased parameter names when function parameters are ambiguous.
func yTown(some: Int, withCallback callback: CoolClosure) -> Bool {
	callback(some)
}

/// Use `$` variable references if the closure fits on one line.
let cool = yTown(5) { $0 == 6 }

/// Use explicit variable names if the closure is on multiple lines.
let cool = yTown(5) { foo in
	max(foo, 0)
	// …
}

// Strongify weak references in async closures.
APIClient.getAwesomeness { [weak self] result in
	guard let self else {
		return
	}

	stopLoadingSpinner()
	show(result)
}

/// Use if-let to check for not `nil` (even if using an implicitly unwrapped variable from an API).
func someUnauditedAPI(thing: String?) {
	if let thing {
		printer.info(thing)
	}
}

/// Infer variable types instead of explicitly declaring them.
let response = Response.success(Data())

func doSomeWork() -> Response {
	let data = Data("", .utf8)
	return .success(data)
}

switch response {
case let .success(data):
	printer.info("The response returned successfully", data)
case let .failure(error):
	printer.error("An error occurred:", error: error)
}

// MARK: Organization

/// Group methods into specific extensions for each level of access control.
private extension MyClass {
	func doSomethingPrivate() {
		// Do something
	}
}

// MARK: Breaking up long lines

// If a guard clause requires multiple lines, chop it down, then start the else
// clause on a new line.
guard
	let oneItem = somethingFailable(),
	let secondItem = somethingFailable2()
else {
	return
}
