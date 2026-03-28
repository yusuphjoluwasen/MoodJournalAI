//
//  MoodJournalAnalytics.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import OSLog
import TelemetryDeck

enum MoodJournalAnalyticsSignal: String {
    case journalAnalyzeRequested = "MoodJournal.journal.analyzeRequested"
    case journalAnalyzeSucceeded = "MoodJournal.journal.analyzeSucceeded"
    case journalAnalyzeFailed = "MoodJournal.journal.analyzeFailed"
    case journalEntrySaved = "MoodJournal.journal.entrySaved"
    case voiceEntryStarted = "MoodJournal.voice.started"
    case voiceEntryCompleted = "MoodJournal.voice.completed"
    case voiceEntryFailed = "MoodJournal.voice.failed"
    case selfCareRefreshRequested = "MoodJournal.selfCare.refreshRequested"
    case selfCareLoaded = "MoodJournal.selfCare.loaded"
    case selfCareLoadFailed = "MoodJournal.selfCare.loadFailed"
    case weeklyReflectionRequested = "MoodJournal.weeklyReflection.requested"
    case weeklyReflectionGenerated = "MoodJournal.weeklyReflection.generated"
    case weeklyReflectionFailed = "MoodJournal.weeklyReflection.failed"
    case reminderEnabled = "MoodJournal.settings.reminderEnabled"
    case reminderDisabled = "MoodJournal.settings.reminderDisabled"
    case reminderUpdated = "MoodJournal.settings.reminderUpdated"
    case reminderFailed = "MoodJournal.settings.reminderFailed"
    case privacyLockEnabled = "MoodJournal.settings.privacyLockEnabled"
    case privacyLockDisabled = "MoodJournal.settings.privacyLockDisabled"
    case privacyLockFailed = "MoodJournal.settings.privacyLockFailed"
    case onboardingCompleted = "MoodJournal.onboarding.completed"
}

@MainActor
final class MoodJournalAnalytics: MoodJournalAnalyticsTracking {
    static let shared = MoodJournalAnalytics()

    private let appID: String
    private var isConfigured = false

    private init() {
        appID = (Bundle.main.object(forInfoDictionaryKey: "TelemetryDeckAppID") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func initialize() {
        guard !isConfigured else { return }
        guard !appID.isEmpty else {
            MoodJournalErrorLogger.app.notice("TelemetryDeck app ID is missing. Analytics is disabled.")
            return
        }

        let config = TelemetryDeck.Config(appID: appID)
        TelemetryDeck.initialize(config: config)
        isConfigured = true
    }

    func track(_ signal: MoodJournalAnalyticsSignal, parameters: [String: String] = [:]) {
        guard isConfigured else { return }
        TelemetryDeck.signal(signal.rawValue, parameters: parameters)
    }
}
