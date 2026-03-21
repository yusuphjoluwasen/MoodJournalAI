//
//  MoodJournalReminderScheduler.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import UserNotifications

enum MoodJournalReminderSchedulerError: LocalizedError {
    case notificationsDenied

    var errorDescription: String? {
        switch self {
        case .notificationsDenied:
            return "Notifications are turned off for this app. Enable them in Settings to use daily reminders."
        }
    }
}

struct MoodJournalReminderScheduler {
    private let center = UNUserNotificationCenter.current()
    private let notificationIdentifier = "MoodJournal.dailyReminder"

    func scheduleDailyReminder(at date: Date) async throws {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        case .notDetermined:
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            guard granted else {
                throw MoodJournalReminderSchedulerError.notificationsDenied
            }
        case .denied:
            throw MoodJournalReminderSchedulerError.notificationsDenied
        @unknown default:
            throw MoodJournalReminderSchedulerError.notificationsDenied
        }

        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Mood Journal"
        content.body = "How are you feeling today? Take a moment to add a quick journal entry."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)

        try await center.add(request)
    }

    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [notificationIdentifier])
    }
}
