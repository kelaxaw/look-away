//
//  NotificationManager.swift
//  look away
//

import AppKit
import UserNotifications

@MainActor
final class NotificationManager {
    private var didRequestAuthorization = false

    func requestAuthorizationIfNeeded() async {
        guard !didRequestAuthorization else { return }
        didRequestAuthorization = true
        do {
            _ = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            // Silently ignore — notifications are a nice-to-have.
        }
    }

    func notifyBreakStarted() {
        NSSound(named: NSSound.Name("Glass"))?.play()

        let content = UNMutableNotificationContent()
        content.title = "Time to look away"
        content.body = "Touch the grass bro"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
}
