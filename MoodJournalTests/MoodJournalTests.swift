//
//  AppleIntelligenceForMyTutorialTests.swift
//  AppleIntelligenceForMyTutorialTests
//
//  Created by Guru King on 15/03/2026.
//

import Foundation
import Testing
@testable import MoodJournal

struct MoodJournalTests {
    @MainActor
    @Test
    func filterEntriesMatchesSearchAndMoodCaseInsensitively() {
        let entries = [
            makeEntry(
                text: "Felt calm after a long walk.",
                createdAt: makeDate(year: 2026, month: 3, day: 20),
                suggestedEmotions: ["Calm", "Reflective"],
                selectedEmotions: ["Calm"],
                reflectionSummary: "A steady day."
            ),
            makeEntry(
                text: "Work left me tense.",
                createdAt: makeDate(year: 2026, month: 3, day: 19),
                suggestedEmotions: ["Stressed"],
                selectedEmotions: ["Stress"],
                reflectionSummary: "AI noticed rising pressure."
            )
        ]

        let searchMatches = MoodJournalStore.filterEntries(entries, searchText: "PRESSURE", selectedMood: nil)
        let moodMatches = MoodJournalStore.filterEntries(entries, searchText: "", selectedMood: "stress")
        let combinedMatches = MoodJournalStore.filterEntries(entries, searchText: "work", selectedMood: "STRESS")

        #expect(searchMatches.count == 1)
        #expect(searchMatches.first?.text == "Work left me tense.")
        #expect(moodMatches.count == 1)
        #expect(moodMatches.first?.selectedEmotions == ["Stress"])
        #expect(combinedMatches.count == 1)
        #expect(combinedMatches.first?.text == "Work left me tense.")
    }

    @MainActor
    @Test
    func groupedHistorySectionsUseFriendlyBuckets() {
        let calendar = gregorianCalendar
        let referenceDate = makeDate(year: 2026, month: 3, day: 20, hour: 12, minute: 0)
        let entries = [
            makeEntry(text: "Today", createdAt: referenceDate),
            makeEntry(text: "Yesterday", createdAt: makeDate(year: 2026, month: 3, day: 19, hour: 11)),
            makeEntry(text: "Earlier", createdAt: makeDate(year: 2026, month: 3, day: 18, hour: 10)),
            makeEntry(text: "Older", createdAt: makeDate(year: 2026, month: 2, day: 28, hour: 9))
        ]

        let sections = MoodJournalStore.groupHistoryEntries(entries, referenceDate: referenceDate, calendar: calendar)

        #expect(sections.map(\.title) == ["Today", "Yesterday", "Earlier This Week", "February 2026"])
        #expect(sections[0].entries.map(\.text) == ["Today"])
        #expect(sections[3].entries.map(\.text) == ["Older"])
    }

    @MainActor
    @Test
    func weeklyMoodTrendsAreSortedAndLimited() {
        let referenceDate = makeDate(year: 2026, month: 3, day: 20, hour: 12)
        let entries = [
            makeEntry(text: "1", createdAt: referenceDate, selectedEmotions: ["Calm", "Joy"]),
            makeEntry(text: "2", createdAt: makeDate(year: 2026, month: 3, day: 19), selectedEmotions: ["Calm", "Stress"]),
            makeEntry(text: "3", createdAt: makeDate(year: 2026, month: 3, day: 18), selectedEmotions: ["Stress", "Focus"]),
            makeEntry(text: "4", createdAt: makeDate(year: 2026, month: 3, day: 17), selectedEmotions: ["Joy", "Focus"]),
            makeEntry(text: "5", createdAt: makeDate(year: 2026, month: 3, day: 16), selectedEmotions: ["Calm", "Tired"]),
            makeEntry(text: "6", createdAt: makeDate(year: 2026, month: 3, day: 15), selectedEmotions: ["Hope"]),
            makeEntry(text: "Old", createdAt: makeDate(year: 2026, month: 3, day: 7), selectedEmotions: ["Anger"])
        ]

        let trends = MoodJournalStore.weeklyMoodTrends(for: entries, referenceDate: referenceDate, calendar: gregorianCalendar)

        #expect(trends.count == 5)
        #expect(trends.map(\.emotion) == ["Calm", "Focus", "Joy", "Stress", "Hope"])
        #expect(trends.map(\.count) == [3, 2, 2, 2, 1])
    }

    @MainActor
    @Test
    func weeklyOverviewComputesCurrentAndLongestStreak() {
        let referenceDate = makeDate(year: 2026, month: 3, day: 20, hour: 12)
        let entries = [
            makeEntry(text: "Today", createdAt: makeDate(year: 2026, month: 3, day: 20), selectedEmotions: ["Calm"]),
            makeEntry(text: "Yesterday", createdAt: makeDate(year: 2026, month: 3, day: 19), selectedEmotions: ["Calm"]),
            makeEntry(text: "This week", createdAt: makeDate(year: 2026, month: 3, day: 18), selectedEmotions: ["Stress"]),
            makeEntry(text: "Past streak 1", createdAt: makeDate(year: 2026, month: 3, day: 10), selectedEmotions: ["Joy"]),
            makeEntry(text: "Past streak 2", createdAt: makeDate(year: 2026, month: 3, day: 9), selectedEmotions: ["Joy"]),
            makeEntry(text: "Past streak 3", createdAt: makeDate(year: 2026, month: 3, day: 8), selectedEmotions: ["Joy"])
        ]

        let overview = MoodJournalStore.weeklyOverview(for: entries, referenceDate: referenceDate, calendar: gregorianCalendar)

        #expect(overview.entriesCount == 3)
        #expect(overview.currentStreak == 3)
        #expect(overview.longestStreak == 3)
        #expect(overview.topEmotions.map(\.emotion) == ["Calm", "Stress"])
    }

    @MainActor
    @Test
    func reminderAndPrivacySettingsPersistLocally() {
        let suiteName = "AppleIntelligenceForMyTutorialTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        let reminderTime = makeDate(year: 2026, month: 3, day: 20, hour: 21, minute: 30)

        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let firstStore = MoodJournalStore(userDefaults: defaults)
        firstStore.setReminderEnabled(true)
        firstStore.setReminderTime(reminderTime)
        firstStore.setPrivacyLockEnabled(true)

        let reloadedStore = MoodJournalStore(userDefaults: defaults)
        let components = gregorianCalendar.dateComponents([.hour, .minute], from: reloadedStore.reminderTime)

        #expect(reloadedStore.reminderEnabled)
        #expect(reloadedStore.privacyLockEnabled)
        #expect(components.hour == 21)
        #expect(components.minute == 30)
    }
}

let gregorianCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
}()

func makeDate(
    year: Int,
    month: Int,
    day: Int,
    hour: Int = 8,
    minute: Int = 0
) -> Date {
    let components = DateComponents(
        calendar: gregorianCalendar,
        timeZone: gregorianCalendar.timeZone,
        year: year,
        month: month,
        day: day,
        hour: hour,
        minute: minute
    )
    return components.date!
}

func makeEntry(
    text: String,
    createdAt: Date,
    suggestedEmotions: [String] = ["Calm"],
    selectedEmotions: [String] = ["Calm"],
    reflectionSummary: String = "A short summary."
) -> JournalEntry {
    JournalEntry(
        id: UUID(),
        text: text,
        createdAt: createdAt,
        suggestedEmotions: suggestedEmotions,
        selectedEmotions: selectedEmotions,
        reflectionSummary: reflectionSummary,
        supportSuggestion: nil
    )
}
