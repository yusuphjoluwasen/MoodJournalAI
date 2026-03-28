import Foundation
import Testing
@testable import MoodJournal

struct MoodJournalHistoryViewModelTests {
    @MainActor
    @Test
    func refreshLoadsMoodOptionsAndDerivedCollections() {
        let store = MockMoodJournalStore()
        let entry = makeEntry(text: "Entry", createdAt: makeDate(year: 2026, month: 3, day: 20))
        store.allSelectedMoodOptions = ["Calm", "Stress"]
        store.weeklyEntries = [entry]
        store.filteredEntriesResult = [entry]
        store.groupedHistorySectionsResult = [JournalHistorySection(title: "Today", entries: [entry])]
        store.dateEntriesResult = [entry]

        let viewModel = MoodJournalHistoryViewModel(store: store)

        #expect(viewModel.availableMoodOptions == ["Calm", "Stress"])
        #expect(viewModel.hasWeeklyReflection)
        #expect(viewModel.filteredEntries == [entry])
        #expect(viewModel.groupedHistoryEntries.count == 1)
        #expect(viewModel.selectedDateEntries == [entry])
    }

    @MainActor
    @Test
    func updatingFiltersRebuildsDerivedState() {
        let store = MockMoodJournalStore()
        let calmEntry = makeEntry(text: "Calm", createdAt: makeDate(year: 2026, month: 3, day: 20), selectedEmotions: ["Calm"])
        let stressEntry = makeEntry(text: "Stress", createdAt: makeDate(year: 2026, month: 3, day: 19), selectedEmotions: ["Stress"])
        store.filteredEntriesResult = [calmEntry]
        store.groupedHistorySectionsResult = [JournalHistorySection(title: "Today", entries: [calmEntry])]
        store.dateEntriesResult = [stressEntry]

        let viewModel = MoodJournalHistoryViewModel(store: store)
        viewModel.updateSearchText("calm")
        viewModel.updateSelectedMood("Calm")

        #expect(viewModel.historySearchText == "calm")
        #expect(viewModel.selectedMoodFilter == "Calm")
        #expect(viewModel.filteredEntries == [calmEntry])
        #expect(viewModel.groupedHistoryEntries.first?.entries == [calmEntry])
    }

    @MainActor
    @Test
    func updatingSelectedDateRefreshesDateEntries() {
        let store = MockMoodJournalStore()
        let selectedDate = makeDate(year: 2026, month: 3, day: 21)
        let entry = makeEntry(text: "Selected day", createdAt: selectedDate)
        store.dateEntriesResult = [entry]

        let viewModel = MoodJournalHistoryViewModel(store: store)
        viewModel.updateSelectedHistoryDate(selectedDate)

        #expect(viewModel.selectedHistoryDate == selectedDate)
        #expect(viewModel.selectedDateEntries == [entry])
    }
}
