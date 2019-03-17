import Foundation

internal class NotificationCollector {
    private(set) var observedNotifications: [Notification]
    private let notificationCenter: NotificationCenter
    #if canImport(Darwin)
    private var token: AnyObject?
    #else
    private var token: NSObjectProtocol?
    #endif

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
        #if canImport(Darwin)
            if let token = self.token {
                self.notificationCenter.removeObserver(token)
            }
        #else
            if let token = self.token as? AnyObject {
                self.notificationCenter.removeObserver(token)
            }
        #endif
    }
}

private let mainThread = pthread_self()

public func postNotifications<T>(
    _ notificationsMatcher: T,
    fromNotificationCenter center: NotificationCenter = .default)
    -> Predicate<Any>
    where T: Matcher, T.ValueType == [Notification]
{
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
