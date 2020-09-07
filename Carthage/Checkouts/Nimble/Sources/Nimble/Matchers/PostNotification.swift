import Foundation

internal class NotificationCollector {
    private(set) var observedNotifications: [Notification]
    private let notificationCenter: NotificationCenter
    private var token: NSObjectProtocol?

    required init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
        self.observedNotifications = []
    }

    func startObserving() {
        // swiftlint:disable:next line_length
        self.token = self.notificationCenter.addObserver(forName: nil, object: nil, queue: nil) { [weak self] notification in
            // linux-swift gets confused by .append(n)
            self?.observedNotifications.append(notification)
        }
    }

    deinit {
        if let token = self.token {
            self.notificationCenter.removeObserver(token)
        }
    }
}

private let mainThread = pthread_self()

public func postNotifications(
    _ predicate: Predicate<[Notification]>,
    from center: NotificationCenter = .default
) -> Predicate<Any> {
    _ = mainThread // Force lazy-loading of this value
    let collector = NotificationCollector(notificationCenter: center)
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
            return .expectedCustomValueTo(message.expectedMessage, actualValue)
        }
        return result
    }
}

@available(*, deprecated, renamed: "postNotifications(_:from:)")
public func postNotifications(
    _ predicate: Predicate<[Notification]>,
    fromNotificationCenter center: NotificationCenter
) -> Predicate<Any> {
    return postNotifications(predicate, from: center)
}

public func postNotifications<T>(
    _ notificationsMatcher: T,
    from center: NotificationCenter = .default
)-> Predicate<Any> where T: Matcher, T.ValueType == [Notification] {
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
)-> Predicate<Any> where T: Matcher, T.ValueType == [Notification] {
    return postNotifications(notificationsMatcher, from: center)
}
