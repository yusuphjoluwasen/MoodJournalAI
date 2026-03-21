//
//  MoodJournalSettingsViewModel.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MoodJournalSettingsViewModel {
    var reminderFeedback = ""
    var privacyLockFeedback = ""

    private let store: MoodJournalStoreProviding
    private let reminderScheduler: MoodJournalReminderScheduling
    private let privacyAuthenticator: MoodJournalPrivacyAuthenticating

    init(
        store: MoodJournalStoreProviding,
        reminderScheduler: MoodJournalReminderScheduling = MoodJournalReminderScheduler(),
        privacyAuthenticator: MoodJournalPrivacyAuthenticating = MoodJournalPrivacyAuthenticator()
    ) {
        self.store = store
        self.reminderScheduler = reminderScheduler
        self.privacyAuthenticator = privacyAuthenticator
    }

    var reminderEnabled: Bool {
        store.reminderEnabled
    }

    var reminderTime: Date {
        store.reminderTime
    }

    var privacyLockEnabled: Bool {
        store.privacyLockEnabled
    }

    func handleReminderToggle(_ isEnabled: Bool) async {
        if isEnabled {
            do {
                try await reminderScheduler.scheduleDailyReminder(at: store.reminderTime)
                store.setReminderEnabled(true)
                reminderFeedback = "Daily reminder scheduled for \(store.reminderTime.formatted(date: .omitted, time: .shortened))."
            } catch {
                store.setReminderEnabled(false)
                reminderFeedback = error.localizedDescription
            }
        } else {
            reminderScheduler.cancelDailyReminder()
            store.setReminderEnabled(false)
            reminderFeedback = "Daily reminder turned off."
        }
    }

    func updateReminderTime(_ newDate: Date) async {
        store.setReminderTime(newDate)

        guard store.reminderEnabled else { return }

        do {
            try await reminderScheduler.scheduleDailyReminder(at: newDate)
            reminderFeedback = "Reminder updated to \(newDate.formatted(date: .omitted, time: .shortened))."
        } catch {
            store.setReminderEnabled(false)
            reminderFeedback = error.localizedDescription
        }
    }

    func handlePrivacyToggle(_ isEnabled: Bool) async {
        if isEnabled {
            do {
                try await privacyAuthenticator.authenticate(reason: "Unlock Mood Journal to enable privacy lock.")
                store.setPrivacyLockEnabled(true)
                privacyLockFeedback = "Privacy lock enabled."
            } catch {
                store.setPrivacyLockEnabled(false)
                privacyLockFeedback = error.localizedDescription
            }
        } else {
            store.setPrivacyLockEnabled(false)
            privacyLockFeedback = "Privacy lock turned off."
        }
    }
}
