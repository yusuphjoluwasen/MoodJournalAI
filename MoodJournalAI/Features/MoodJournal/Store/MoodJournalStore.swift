//
//  MoodJournalStore.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import Observation
import SwiftData

struct JournalHistorySection: Identifiable, Hashable {
    let title: String
    let entries: [JournalEntry]

    var id: String { title }
}

@MainActor
@Observable
final class MoodJournalStore {
    private let legacyStorageKey = "MoodJournal.entries"
    private let legacyMigrationKey = "MoodJournal.entriesMigratedToSwiftData"
    private let reminderEnabledKey = "MoodJournal.reminderEnabled"
    private let reminderHourKey = "MoodJournal.reminderHour"
    private let reminderMinuteKey = "MoodJournal.reminderMinute"
    private let privacyLockEnabledKey = "MoodJournal.privacyLockEnabled"
    private let userDefaults: UserDefaults
    private var modelContext: ModelContext?

    private(set) var entries: [JournalEntry] = []
    private(set) var reminderEnabled = false
    private(set) var reminderTime = Date()
    private(set) var privacyLockEnabled = false
    private var cachedWeeklyOverview = WeeklyMoodOverview(entriesCount: 0, currentStreak: 0, longestStreak: 0, topEmotions: [])
    private var cachedAllSelectedMoodOptions: [String] = []
    private var cachedWeeklyEntries: [JournalEntry] = []
    private var cachedWeeklyMoodTrends: [MoodTrendDatum] = []

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        loadReminderSettings()
        loadPrivacySettings()
    }

    func configure(modelContext: ModelContext) {
        let needsInitialLoad = self.modelContext == nil
        self.modelContext = modelContext

        guard needsInitialLoad else { return }

        migrateLegacyEntriesIfNeeded()
        loadEntries()
    }

    var weeklyOverview: WeeklyMoodOverview {
        cachedWeeklyOverview
    }

    var allSelectedMoodOptions: [String] {
        cachedAllSelectedMoodOptions
    }

    var weeklyEntries: [JournalEntry] {
        cachedWeeklyEntries
    }

    var weeklyMoodTrends: [MoodTrendDatum] {
        cachedWeeklyMoodTrends
    }

    func filteredEntries(searchText: String, selectedMood: String?) -> [JournalEntry] {
        Self.filterEntries(entries, searchText: searchText, selectedMood: selectedMood)
    }

    func groupedHistorySections(searchText: String, selectedMood: String?, referenceDate: Date = Date()) -> [JournalHistorySection] {
        let filtered = filteredEntries(searchText: searchText, selectedMood: selectedMood)
        return Self.groupHistoryEntries(filtered, referenceDate: referenceDate)
    }

    func entries(on date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDate($0.createdAt, inSameDayAs: date) }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func addEntry(
        text: String,
        suggestedEmotions: [String],
        selectedEmotions: [String],
        reflectionSummary: String,
        supportSuggestion: SupportSuggestion?
    ) {
        let entry = JournalEntry(
            id: UUID(),
            text: text,
            createdAt: Date(),
            suggestedEmotions: suggestedEmotions,
            selectedEmotions: selectedEmotions,
            reflectionSummary: reflectionSummary,
            supportSuggestion: supportSuggestion
        )
        save(entry)
    }

    func deleteEntry(id: UUID) {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<JournalEntryRecord>()
            let records = try modelContext.fetch(descriptor)

            guard let record = records.first(where: { $0.id == id }) else { return }

            modelContext.delete(record)
            try modelContext.save()
            loadEntries()
        } catch {
            assertionFailure("Failed to delete mood journal entry: \(error)")
        }
    }

    func setReminderEnabled(_ isEnabled: Bool) {
        reminderEnabled = isEnabled
        userDefaults.set(isEnabled, forKey: reminderEnabledKey)
    }

    func setReminderTime(_ date: Date) {
        reminderTime = date

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        userDefaults.set(components.hour, forKey: reminderHourKey)
        userDefaults.set(components.minute, forKey: reminderMinuteKey)
    }

    func setPrivacyLockEnabled(_ isEnabled: Bool) {
        privacyLockEnabled = isEnabled
        userDefaults.set(isEnabled, forKey: privacyLockEnabledKey)
    }

    func weeklyExportText(recap: String, insight: String) -> String {
        let overview = weeklyOverview
        let topMoodLines = overview.topEmotions.map { "\($0.emotion): \($0.count)" }.joined(separator: "\n")
        let entryLines = weeklyEntries.map {
            """
            Date: \($0.createdAt.formatted(date: .abbreviated, time: .shortened))
            Selected moods: \($0.selectedEmotions.joined(separator: ", "))
            Reflection summary: \($0.reflectionSummary)
            """
        }.joined(separator: "\n\n")

        return """
        Mood Journal Weekly Summary

        Entries this week: \(overview.entriesCount)
        Current streak: \(overview.currentStreak)
        Longest streak: \(overview.longestStreak)

        Top confirmed moods:
        \(topMoodLines.isEmpty ? "No confirmed moods yet." : topMoodLines)

        AI Weekly Recap:
        \(recap.isEmpty ? "No recap available." : recap)

        Health-Style Pattern Insight:
        \(insight.isEmpty ? "No insight available." : insight)

        Weekly Entries:
        \(entryLines.isEmpty ? "No entries available." : entryLines)
        """
    }

    static func filterEntries(_ entries: [JournalEntry], searchText: String, selectedMood: String?) -> [JournalEntry] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedMood = selectedMood?.lowercased()

        return entries.filter { entry in
            let matchesSearch: Bool
            if trimmedSearch.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch =
                    entry.text.lowercased().contains(trimmedSearch) ||
                    entry.selectedEmotions.contains { $0.lowercased().contains(trimmedSearch) } ||
                    entry.suggestedEmotions.contains { $0.lowercased().contains(trimmedSearch) } ||
                    entry.reflectionSummary.lowercased().contains(trimmedSearch)
            }

            let matchesMood: Bool
            if let normalizedMood {
                matchesMood = entry.selectedEmotions.contains { $0.lowercased() == normalizedMood }
            } else {
                matchesMood = true
            }

            return matchesSearch && matchesMood
        }
    }

    static func groupHistoryEntries(
        _ entries: [JournalEntry],
        referenceDate: Date,
        calendar: Calendar = .current
    ) -> [JournalHistorySection] {
        let today = calendar.startOfDay(for: referenceDate)
        let thisWeekInterval = calendar.dateInterval(of: .weekOfYear, for: today)

        let grouped = Dictionary(grouping: entries) { entry in
            let day = calendar.startOfDay(for: entry.createdAt)

            if calendar.isDate(day, inSameDayAs: today) {
                return "Today"
            }

            if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
               calendar.isDate(day, inSameDayAs: yesterday) {
                return "Yesterday"
            }

            if let thisWeekInterval, thisWeekInterval.contains(day) {
                return "Earlier This Week"
            }

            return monthYearFormatter.string(from: day)
        }

        return grouped
            .map { title, entries in
                JournalHistorySection(
                    title: title,
                    entries: entries.sorted { $0.createdAt > $1.createdAt }
                )
            }
            .sorted { lhs, rhs in
                guard
                    let lhsDate = lhs.entries.first?.createdAt,
                    let rhsDate = rhs.entries.first?.createdAt
                else {
                    return lhs.title < rhs.title
                }

                return lhsDate > rhsDate
            }
    }

    static func weeklyMoodTrends(
        for entries: [JournalEntry],
        referenceDate: Date,
        calendar: Calendar = .current
    ) -> [MoodTrendDatum] {
        let grouped = Dictionary(grouping: entriesThisWeek(entries, referenceDate: referenceDate, calendar: calendar).flatMap(\.selectedEmotions)) { $0.lowercased() }

        return grouped
            .map { key, values in MoodTrendDatum(emotion: key.capitalized, count: values.count) }
            .sorted {
                if $0.count == $1.count {
                    return $0.emotion < $1.emotion
                }
                return $0.count > $1.count
            }
            .prefix(5)
            .map { $0 }
    }

    static func weeklyOverview(
        for entries: [JournalEntry],
        referenceDate: Date,
        calendar: Calendar = .current
    ) -> WeeklyMoodOverview {
        let weekEntries = entriesThisWeek(entries, referenceDate: referenceDate, calendar: calendar)
        let grouped = Dictionary(grouping: weekEntries.flatMap(\.selectedEmotions)) { $0.lowercased() }
        let topEmotions = grouped
            .map { key, values in MoodFrequency(emotion: key.capitalized, count: values.count) }
            .sorted {
                if $0.count == $1.count {
                    return $0.emotion < $1.emotion
                }
                return $0.count > $1.count
            }
            .prefix(2)

        return WeeklyMoodOverview(
            entriesCount: weekEntries.count,
            currentStreak: currentStreak(for: entries, referenceDate: referenceDate, calendar: calendar),
            longestStreak: longestStreak(for: entries, calendar: calendar),
            topEmotions: Array(topEmotions)
        )
    }

    private func entriesThisWeek(referenceDate: Date) -> [JournalEntry] {
        Self.entriesThisWeek(entries, referenceDate: referenceDate)
    }

    private static func entriesThisWeek(
        _ entries: [JournalEntry],
        referenceDate: Date,
        calendar: Calendar = .current
    ) -> [JournalEntry] {
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start ?? .distantPast
        return entries.filter { $0.createdAt >= startOfWeek }
    }

    private var currentStreak: Int {
        Self.currentStreak(for: entries, referenceDate: Date())
    }

    private var longestStreak: Int {
        Self.longestStreak(for: entries)
    }

    private var uniqueEntryDays: [Date] {
        Self.uniqueEntryDays(for: entries)
    }

    private func streakLength(for days: [Date]) -> Int {
        Self.streakLength(for: days)
    }

    private static func currentStreak(
        for entries: [JournalEntry],
        referenceDate: Date,
        calendar: Calendar = .current
    ) -> Int {
        streakLength(for: uniqueEntryDays(for: entries, calendar: calendar), referenceDate: referenceDate, calendar: calendar)
    }

    private static func longestStreak(
        for entries: [JournalEntry],
        calendar: Calendar = .current
    ) -> Int {
        let days = uniqueEntryDays(for: entries, calendar: calendar)
        guard !days.isEmpty else { return 0 }

        var longest = 1
        var running = 1

        for index in 1..<days.count {
            let previous = days[index - 1]
            let current = days[index]
            let delta = calendar.dateComponents([.day], from: current, to: previous).day ?? 0

            if delta == 1 {
                running += 1
                longest = max(longest, running)
            } else if delta > 1 {
                running = 1
            }
        }

        return longest
    }

    private static func uniqueEntryDays(
        for entries: [JournalEntry],
        calendar: Calendar = .current
    ) -> [Date] {
        let days = entries.map { calendar.startOfDay(for: $0.createdAt) }
        let unique = Array(Set(days))
        return unique.sorted(by: >)
    }

    private static func streakLength(
        for days: [Date],
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        guard !days.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: referenceDate)
        guard let first = days.first else { return 0 }

        let offsetFromToday = calendar.dateComponents([.day], from: first, to: today).day ?? 0
        guard offsetFromToday <= 1 else { return 0 }

        var streak = 1
        var expected = first

        for day in days.dropFirst() {
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: expected) else { break }

            if calendar.isDate(day, inSameDayAs: previousDay) {
                streak += 1
                expected = day
            } else {
                break
            }
        }

        return streak
    }

    private func loadEntries() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<JournalEntryRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        do {
            entries = try modelContext.fetch(descriptor).compactMap { try? $0.makeEntry() }
            refreshDerivedState()
        } catch {
            entries = []
            refreshDerivedState()
        }
    }

    private func loadReminderSettings() {
        reminderEnabled = userDefaults.bool(forKey: reminderEnabledKey)

        let storedHour = userDefaults.object(forKey: reminderHourKey) as? Int
        let storedMinute = userDefaults.object(forKey: reminderMinuteKey) as? Int

        if let storedHour, let storedMinute {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            components.hour = storedHour
            components.minute = storedMinute
            reminderTime = Calendar.current.date(from: components) ?? defaultReminderTime
        } else {
            reminderTime = defaultReminderTime
        }
    }

    private func loadPrivacySettings() {
        privacyLockEnabled = userDefaults.bool(forKey: privacyLockEnabledKey)
    }

    private var defaultReminderTime: Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 20
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }

    private func save(_ entry: JournalEntry) {
        guard let modelContext else { return }

        do {
            modelContext.insert(try JournalEntryRecord(entry: entry))
            try modelContext.save()
            loadEntries()
        } catch {
            assertionFailure("Failed to persist mood journal entry: \(error)")
        }
    }

    private func migrateLegacyEntriesIfNeeded() {
        guard let modelContext else { return }
        guard !userDefaults.bool(forKey: legacyMigrationKey) else { return }
        guard let data = userDefaults.data(forKey: legacyStorageKey) else {
            userDefaults.set(true, forKey: legacyMigrationKey)
            return
        }

        do {
            let legacyEntries = try JSONDecoder().decode([JournalEntry].self, from: data)
            let existingRecords = try modelContext.fetch(FetchDescriptor<JournalEntryRecord>())
            let existingIDs = Set(existingRecords.map(\.id))

            for entry in legacyEntries where !existingIDs.contains(entry.id) {
                modelContext.insert(try JournalEntryRecord(entry: entry))
            }

            if modelContext.hasChanges {
                try modelContext.save()
            }

            userDefaults.removeObject(forKey: legacyStorageKey)
            userDefaults.set(true, forKey: legacyMigrationKey)
        } catch {
            assertionFailure("Failed to migrate legacy mood journal entries: \(error)")
        }
    }

    private func refreshDerivedState(referenceDate: Date = Date()) {
        cachedWeeklyEntries = entriesThisWeek(referenceDate: referenceDate).sorted { $0.createdAt > $1.createdAt }
        cachedWeeklyOverview = Self.weeklyOverview(for: entries, referenceDate: referenceDate)
        cachedWeeklyMoodTrends = Self.weeklyMoodTrends(for: entries, referenceDate: referenceDate)
        cachedAllSelectedMoodOptions = Array(Set(entries.flatMap(\.selectedEmotions).map { $0.capitalized })).sorted()
    }
}
private let monthYearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    return formatter
}()
