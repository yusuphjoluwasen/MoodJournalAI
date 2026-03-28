import Foundation
import Testing
@testable import MoodJournal

struct SelfCareTipsViewModelTests {
    @MainActor
    @Test
    func generateTipSetsTipOnSuccess() async {
        let analyzer = MockMoodJournalAnalyzer(
            selfCareTipHandler: { SelfCareTip(title: "Reset", tip: "Pause and breathe.") }
        )
        let viewModel = SelfCareTipsViewModel(analyzer: analyzer)

        await viewModel.generateTip()

        #expect(viewModel.tip?.title == "Reset")
        #expect(viewModel.errorState == nil)
        #expect(!viewModel.isLoading)
    }

    @MainActor
    @Test
    func generateTipSetsErrorStateOnFailure() async {
        let analyzer = MockMoodJournalAnalyzer(
            selfCareTipHandler: { throw MockError(message: "Tip failed") }
        )
        let viewModel = SelfCareTipsViewModel(analyzer: analyzer)

        await viewModel.generateTip()

        #expect(viewModel.tip == nil)
        #expect(viewModel.errorState?.title == "Couldn’t load a tip")
    }

    @MainActor
    @Test
    func refreshChangesRefreshIdentifier() {
        let viewModel = SelfCareTipsViewModel(analyzer: MockMoodJournalAnalyzer())
        let previous = viewModel.refreshID

        viewModel.refresh()

        #expect(viewModel.refreshID != previous)
    }
}
