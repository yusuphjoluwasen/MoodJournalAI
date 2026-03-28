import Foundation
@testable import MoodJournal

@MainActor
final class MockMoodJournalStore: MoodJournalStoreProviding {
    var weeklyOverview = WeeklyMoodOverview(entriesCount: 0, currentStreak: 0, longestStreak: 0, topEmotions: [])
    var weeklyEntries: [JournalEntry] = []
    var allSelectedMoodOptions: [String] = []
    var entries: [JournalEntry] = []
    var reminderEnabled = false
    var reminderTime = Date()
    var privacyLockEnabled = false

    var addedEntries: [(text: String, suggestedEmotions: [String], selectedEmotions: [String], reflectionSummary: String, supportSuggestion: SupportSuggestion?)] = []
    var exportText = "Export"
    var filteredEntriesResult: [JournalEntry] = []
    var groupedHistorySectionsResult: [JournalHistorySection] = []
    var dateEntriesResult: [JournalEntry] = []

    func addEntry(
        text: String,
        suggestedEmotions: [String],
        selectedEmotions: [String],
        reflectionSummary: String,
        supportSuggestion: SupportSuggestion?
    ) {
        addedEntries.append((text, suggestedEmotions, selectedEmotions, reflectionSummary, supportSuggestion))
    }

    func setReminderEnabled(_ isEnabled: Bool) {
        reminderEnabled = isEnabled
    }

    func setReminderTime(_ date: Date) {
        reminderTime = date
    }

    func setPrivacyLockEnabled(_ isEnabled: Bool) {
        privacyLockEnabled = isEnabled
    }

    func weeklyExportText(recap: String, insight: String) -> String {
        exportText + " \(recap) \(insight)"
    }

    func filteredEntries(searchText: String, selectedMood: String?) -> [JournalEntry] {
        filteredEntriesResult
    }

    func groupedHistorySections(searchText: String, selectedMood: String?, referenceDate: Date) -> [JournalHistorySection] {
        groupedHistorySectionsResult
    }

    func entries(on date: Date) -> [JournalEntry] {
        dateEntriesResult
    }
}

struct MockMoodJournalAnalyzer: MoodJournalAnalyzing {
    var analyzeHandler: @Sendable (String) async throws -> MoodJournalAnalysisResult = { _ in
        MoodJournalAnalysisResult(
            suggestedEmotions: ["Calm"],
            reflectionSummary: "A steady day.",
            supportSuggestion: SupportSuggestion(title: "Rest", detail: "Pause for a moment.", symbol: "bed.double.fill")
        )
    }
    var selfCareTipHandler: @Sendable () async throws -> SelfCareTip = {
        SelfCareTip(title: "Reset", tip: "Take a breath.")
    }
    var weeklyRecapHandler: @Sendable ([JournalEntry]) async throws -> String = { _ in
        "Weekly recap"
    }
    var weeklyHealthInsightHandler: @Sendable ([JournalEntry]) async throws -> String = { _ in
        "Weekly insight"
    }

    func analyze(text: String) async throws -> MoodJournalAnalysisResult {
        try await analyzeHandler(text)
    }

    func selfCareTip() async throws -> SelfCareTip {
        try await selfCareTipHandler()
    }

    func weeklyRecap(for entries: [JournalEntry]) async throws -> String {
        try await weeklyRecapHandler(entries)
    }

    func weeklyHealthInsight(for entries: [JournalEntry]) async throws -> String {
        try await weeklyHealthInsightHandler(entries)
    }
}

@MainActor
final class MockVoiceJournalTranscriber: VoiceJournalTranscribing {
    var startError: Error?
    var didStop = false
    var completion: (@MainActor (Result<String, Error>) -> Void)?

    func startTranscribing(
        locale: Locale,
        onCompletion: @escaping @MainActor (Result<String, Error>) -> Void
    ) async throws {
        if let startError {
            throw startError
        }

        completion = onCompletion
    }

    func stopTranscribing() {
        didStop = true
    }
}

struct MockReminderScheduler: MoodJournalReminderScheduling {
    var scheduleHandler: @Sendable (Date) async throws -> Void = { _ in }
    var cancelHandler: @Sendable () -> Void = {}

    func scheduleDailyReminder(at date: Date) async throws {
        try await scheduleHandler(date)
    }

    func cancelDailyReminder() {
        cancelHandler()
    }
}

struct MockPrivacyAuthenticator: MoodJournalPrivacyAuthenticating {
    var authenticateHandler: @Sendable (String) async throws -> Void = { _ in }

    func authenticate(reason: String) async throws {
        try await authenticateHandler(reason)
    }
}

struct MockError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}
