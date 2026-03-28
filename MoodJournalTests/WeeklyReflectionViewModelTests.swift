import Foundation
import Testing
@testable import MoodJournal

struct WeeklyReflectionViewModelTests {
    @MainActor
    @Test
    func generateReflectionsPopulatesRecapAndInsight() async {
        let store = MockMoodJournalStore()
        store.weeklyEntries = [makeEntry(text: "Day", createdAt: makeDate(year: 2026, month: 3, day: 20))]
        let analyzer = MockMoodJournalAnalyzer(
            weeklyRecapHandler: { _ in "Recap" },
            weeklyHealthInsightHandler: { _ in "Insight" }
        )
        let viewModel = WeeklyReflectionViewModel(store: store, analyzer: analyzer)

        await viewModel.generateReflections()

        #expect(viewModel.recap == "Recap")
        #expect(viewModel.insight == "Insight")
        #expect(viewModel.errorState == nil)
        #expect(viewModel.exportText.contains("Recap"))
    }

    @MainActor
    @Test
    func generateReflectionsSetsErrorStateOnFailure() async {
        let store = MockMoodJournalStore()
        store.weeklyEntries = [makeEntry(text: "Day", createdAt: makeDate(year: 2026, month: 3, day: 20))]
        let analyzer = MockMoodJournalAnalyzer(
            weeklyRecapHandler: { _ in throw MockError(message: "No recap") }
        )
        let viewModel = WeeklyReflectionViewModel(store: store, analyzer: analyzer)

        await viewModel.generateReflections()

        #expect(viewModel.recap.isEmpty)
        #expect(viewModel.insight.isEmpty)
        #expect(viewModel.errorState?.title == "Couldn’t generate your reflection")
    }
}
