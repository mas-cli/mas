#if canImport(Foundation)
import Foundation

internal class NotificationCollector {
    private(set) var observedNotifications: [Notification]
    private let notificationCenter: NotificationCenter
    private let names: Set<Notification.Name>
    private var tokens: [NSObjectProtocol]

    required init(notificationCenter: NotificationCenter, names: Set<Notification.Name> = []) {
        self.notificationCenter = notificationCenter
        self.observedNotifications = []
        self.names = names
        self.tokens = []
    }

    func startObserving() {
        func addObserver(forName name: Notification.Name?) -> NSObjectProtocol {
            return notificationCenter.addObserver(forName: name, object: nil, queue: nil) { [weak self] notification in
                // linux-swift gets confused by .append(n)
                self?.observedNotifications.append(notification)
            }
        }

        if names.isEmpty {
            tokens.append(addObserver(forName: nil))
        } else {
            names.forEach { name in
                tokens.append(addObserver(forName: name))
            }
        }
    }

    deinit {
        tokens.forEach { token in
            notificationCenter.removeObserver(token)
        }
    }
}

private let mainThread = pthread_self()

private func _postNotifications<Out>(
    _ predicate: Predicate<[Notification]>,
    from center: NotificationCenter,
    names: Set<Notification.Name> = []
) -> Predicate<Out> {
    _ = mainThread // Force lazy-loading of this value
    let collector = NotificationCollector(notificationCenter: center, names: names)
    collector.startObserving()
    var once: Bool = false

    return Predicate { actualExpression in
        let collectorNotificationsExpression = Expression(
            memoizedExpression: { _ in
                return collector.observedNotifications
            },
            location: actualExpression.location,
            withoutCaching: true
        )

        assert(pthread_equal(mainThread, pthread_self()) != 0, "Only expecting closure to be evaluated on main thread.")
        if !once {
            once = true
            _ = try actualExpression.evaluate()
        }

        let actualValue: String
        if collector.observedNotifications.isEmpty {
            actualValue = "no notifications"
        } else {
            actualValue = "<\(stringify(collector.observedNotifications))>"
        }

        var result = try predicate.satisfies(collectorNotificationsExpression)
        result.message = result.message.replacedExpectation { message in
            return .expectedCustomValueTo(message.expectedMessage, actual: actualValue)
        }
        return result
    }
}

public func postNotifications<Out>(
    _ predicate: Predicate<[Notification]>,
    from center: NotificationCenter = .default
) -> Predicate<Out> {
    _postNotifications(predicate, from: center)
}

@available(*, deprecated, renamed: "postNotifications(_:from:)")
public func postNotifications<Out>(
    _ predicate: Predicate<[Notification]>,
    fromNotificationCenter center: NotificationCenter
) -> Predicate<Out> {
    postNotifications(predicate, from: center)
}

#if os(macOS)
public func postDistributedNotifications<Out>(
    _ predicate: Predicate<[Notification]>,
    from center: DistributedNotificationCenter = .default(),
    names: Set<Notification.Name>
) -> Predicate<Out> {
    _postNotifications(predicate, from: center, names: names)
}
#endif

@available(*, deprecated, message: "Use Predicate instead")
public func postNotifications<T>(
    _ notificationsMatcher: T,
    from center: NotificationCenter = .default
) -> Predicate<Any> where T: Matcher, T.ValueType == [Notification] {
    _ = mainThread // Force lazy-loading of this value
    let collector = NotificationCollector(notificationCenter: center)
    collector.startObserving()
    var once: Bool = false

    return Predicate { actualExpression in
        let collectorNotificationsExpression = Expression(memoizedExpression: { _ in
            return collector.observedNotifications
            }, location: actualExpression.location, withoutCaching: true)

        assert(pthread_equal(mainThread, pthread_self()) != 0, "Only expecting closure to be evaluated on main thread.")
        if !once {
            once = true
            _ = try actualExpression.evaluate()
        }

        let failureMessage = FailureMessage()
        let match = try notificationsMatcher.matches(collectorNotificationsExpression, failureMessage: failureMessage)
        if collector.observedNotifications.isEmpty {
            failureMessage.actualValue = "no notifications"
        } else {
            failureMessage.actualValue = "<\(stringify(collector.observedNotifications))>"
        }
        return PredicateResult(bool: match, message: failureMessage.toExpectationMessage())
    }
}

@available(*, deprecated, renamed: "postNotifications(_:from:)")
public func postNotifications<T>(
    _ notificationsMatcher: T,
    fromNotificationCenter center: NotificationCenter
) -> Predicate<Any> where T: Matcher, T.ValueType == [Notification] {
    return postNotifications(notificationsMatcher, from: center)
}
#endif
