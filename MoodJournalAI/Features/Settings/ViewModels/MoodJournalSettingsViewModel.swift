//
//  MoodJournalSettingsViewModel.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import Observation
import OSLog

@MainActor
@Observable
final class MoodJournalSettingsViewModel {
    var reminderFeedback = ""
    var privacyLockFeedback = ""

    private let store: MoodJournalStoreProviding
    private let reminderScheduler: MoodJournalReminderScheduling
    private let privacyAuthenticator: MoodJournalPrivacyAuthenticating

    convenience init(store: MoodJournalStoreProviding) {
        self.init(
            store: store,
            reminderScheduler: MoodJournalReminderScheduler(),
            privacyAuthenticator: MoodJournalPrivacyAuthenticator()
        )
    }

    init(
        store: MoodJournalStoreProviding,
        reminderScheduler: MoodJournalReminderScheduling,
        privacyAuthenticator: MoodJournalPrivacyAuthenticating
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
                MoodJournalErrorLogger.settings.error("Reminder toggle failed: \(String(describing: error), privacy: .public)")
                reminderFeedback = MoodJournalUserErrorMapper.reminderMessage(for: error)
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
            MoodJournalErrorLogger.settings.error("Reminder time update failed: \(String(describing: error), privacy: .public)")
            reminderFeedback = MoodJournalUserErrorMapper.reminderMessage(for: error)
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
                MoodJournalErrorLogger.settings.error("Privacy toggle failed: \(String(describing: error), privacy: .public)")
                privacyLockFeedback = MoodJournalUserErrorMapper.privacyMessage(for: error)
            }
        } else {
            store.setPrivacyLockEnabled(false)
            privacyLockFeedback = "Privacy lock turned off."
        }
    }
}
