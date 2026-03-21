//
//  MoodJournalHistoryViewModel.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MoodJournalHistoryViewModel {
    var historyMode: MoodJournalHistoryView.HistoryMode = .list
    var historySearchText = ""
    var selectedMoodFilter: String?
    var selectedHistoryDate = Date()
    var isShowingWeeklyReflection = false

    private(set) var filteredEntries: [JournalEntry] = []
    private(set) var groupedHistoryEntries: [JournalHistorySection] = []
    private(set) var selectedDateEntries: [JournalEntry] = []
    private(set) var availableMoodOptions: [String] = []
    private(set) var hasWeeklyReflection = false

    private let store: MoodJournalStoreProviding

    init(store: MoodJournalStoreProviding) {
        self.store = store
        refresh()
    }

    func updateSearchText(_ value: String) {
        historySearchText = value
        rebuildDerivedState()
    }

    func updateSelectedMood(_ mood: String?) {
        selectedMoodFilter = mood
        rebuildDerivedState()
    }

    func updateSelectedHistoryDate(_ date: Date) {
        selectedHistoryDate = date
        selectedDateEntries = store.entries(on: date)
    }

    func refresh() {
        availableMoodOptions = store.allSelectedMoodOptions
        hasWeeklyReflection = !store.weeklyEntries.isEmpty
        rebuildDerivedState()
    }

    private func rebuildDerivedState() {
        filteredEntries = store.filteredEntries(
            searchText: historySearchText,
            selectedMood: selectedMoodFilter
        )
        groupedHistoryEntries = store.groupedHistorySections(
            searchText: historySearchText,
            selectedMood: selectedMoodFilter,
            referenceDate: Date()
        )
        selectedDateEntries = store.entries(on: selectedHistoryDate)
    }
}
