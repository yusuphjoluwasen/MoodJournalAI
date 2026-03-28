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
    private let analytics: MoodJournalAnalyticsTracking

    convenience init(store: MoodJournalStoreProviding) {
        self.init(
            store: store,
            reminderScheduler: MoodJournalReminderScheduler(),
            privacyAuthenticator: MoodJournalPrivacyAuthenticator(),
            analytics: MoodJournalAnalytics.shared
        )
    }

    init(
        store: MoodJournalStoreProviding,
        reminderScheduler: MoodJournalReminderScheduling,
        privacyAuthenticator: MoodJournalPrivacyAuthenticating,
        analytics: MoodJournalAnalyticsTracking? = nil
    ) {
        self.store = store
        self.reminderScheduler = reminderScheduler
        self.privacyAuthenticator = privacyAuthenticator
        self.analytics = analytics ?? MoodJournalAnalytics.shared
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
                analytics.track(.reminderEnabled, parameters: [:])
                reminderFeedback = "Daily reminder scheduled for \(store.reminderTime.formatted(date: .omitted, time: .shortened))."
            } catch {
                store.setReminderEnabled(false)
                MoodJournalErrorLogger.settings.error("Reminder toggle failed: \(String(describing: error), privacy: .public)")
                analytics.track(.reminderFailed, parameters: [:])
                reminderFeedback = MoodJournalUserErrorMapper.reminderMessage(for: error)
            }
        } else {
            reminderScheduler.cancelDailyReminder()
            store.setReminderEnabled(false)
            analytics.track(.reminderDisabled, parameters: [:])
            reminderFeedback = "Daily reminder turned off."
        }
    }

    func updateReminderTime(_ newDate: Date) async {
        store.setReminderTime(newDate)

        guard store.reminderEnabled else { return }

        do {
            try await reminderScheduler.scheduleDailyReminder(at: newDate)
            analytics.track(.reminderUpdated, parameters: [:])
            reminderFeedback = "Reminder updated to \(newDate.formatted(date: .omitted, time: .shortened))."
        } catch {
            store.setReminderEnabled(false)
            MoodJournalErrorLogger.settings.error("Reminder time update failed: \(String(describing: error), privacy: .public)")
            analytics.track(.reminderFailed, parameters: [:])
            reminderFeedback = MoodJournalUserErrorMapper.reminderMessage(for: error)
        }
    }

    func handlePrivacyToggle(_ isEnabled: Bool) async {
        if isEnabled {
            do {
                try await privacyAuthenticator.authenticate(reason: "Unlock Mood Journal to enable privacy lock.")
                store.setPrivacyLockEnabled(true)
                analytics.track(.privacyLockEnabled, parameters: [:])
                privacyLockFeedback = "Privacy lock enabled."
            } catch {
                store.setPrivacyLockEnabled(false)
                MoodJournalErrorLogger.settings.error("Privacy toggle failed: \(String(describing: error), privacy: .public)")
                analytics.track(.privacyLockFailed, parameters: [:])
                privacyLockFeedback = MoodJournalUserErrorMapper.privacyMessage(for: error)
            }
        } else {
            store.setPrivacyLockEnabled(false)
            analytics.track(.privacyLockDisabled, parameters: [:])
            privacyLockFeedback = "Privacy lock turned off."
        }
    }
}
