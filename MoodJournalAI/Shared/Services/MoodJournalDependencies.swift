//
//  MoodJournalDependencies.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation

protocol MoodJournalStoreProviding: AnyObject {
    var weeklyOverview: WeeklyMoodOverview { get }
    var weeklyEntries: [JournalEntry] { get }
    var allSelectedMoodOptions: [String] { get }
    var entries: [JournalEntry] { get }
    var reminderEnabled: Bool { get }
    var reminderTime: Date { get }
    var privacyLockEnabled: Bool { get }

    func addEntry(
        text: String,
        suggestedEmotions: [String],
        selectedEmotions: [String],
        reflectionSummary: String,
        supportSuggestion: SupportSuggestion?
    )

    func setReminderEnabled(_ isEnabled: Bool)
    func setReminderTime(_ date: Date)
    func setPrivacyLockEnabled(_ isEnabled: Bool)
    func weeklyExportText(recap: String, insight: String) -> String
    func filteredEntries(searchText: String, selectedMood: String?) -> [JournalEntry]
    func groupedHistorySections(searchText: String, selectedMood: String?, referenceDate: Date) -> [JournalHistorySection]
    func entries(on date: Date) -> [JournalEntry]
}

protocol MoodJournalAnalyzing {
    func analyze(text: String) async throws -> MoodJournalAnalysisResult
    func selfCareTip() async throws -> SelfCareTip
    func weeklyRecap(for entries: [JournalEntry]) async throws -> String
    func weeklyHealthInsight(for entries: [JournalEntry]) async throws -> String
}

protocol VoiceJournalTranscribing: AnyObject {
    func startTranscribing(
        locale: Locale,
        onCompletion: @escaping @MainActor (Result<String, Error>) -> Void
    ) async throws
    func stopTranscribing()
}

protocol MoodJournalReminderScheduling {
    func scheduleDailyReminder(at date: Date) async throws
    func cancelDailyReminder()
}

protocol MoodJournalPrivacyAuthenticating {
    func authenticate(reason: String) async throws
}

protocol MoodJournalAnalyticsTracking: AnyObject {
    func initialize()
    func track(_ signal: MoodJournalAnalyticsSignal, parameters: [String: String])
}

extension MoodJournalStore: MoodJournalStoreProviding {}
extension MoodJournalAnalyzer: MoodJournalAnalyzing {}
extension VoiceJournalTranscriber: VoiceJournalTranscribing {}
extension MoodJournalReminderScheduler: MoodJournalReminderScheduling {}
extension MoodJournalPrivacyAuthenticator: MoodJournalPrivacyAuthenticating {}
