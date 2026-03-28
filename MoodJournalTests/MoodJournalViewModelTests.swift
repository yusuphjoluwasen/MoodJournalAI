import Foundation
import Testing
@testable import MoodJournal

struct MoodJournalViewModelTests {
    @MainActor
    @Test
    func analyzeEntryPopulatesDraftOnSuccess() async {
        let store = MockMoodJournalStore()
        let analyzer = MockMoodJournalAnalyzer(
            analyzeHandler: { text in
                #expect(text == "Today felt heavy")
                return MoodJournalAnalysisResult(
                    suggestedEmotions: ["Stress", "Hope"],
                    reflectionSummary: "You felt pressure but kept going.",
                    supportSuggestion: SupportSuggestion(title: "Breathing Break", detail: "Take five breaths.", symbol: "wind")
                )
            }
        )
        let viewModel = MoodJournalViewModel(store: store, analyzer: analyzer, voiceJournalTranscriber: MockVoiceJournalTranscriber())
        viewModel.draft.inputText = "Today felt heavy"

        await viewModel.analyzeEntry()

        #expect(viewModel.draft.suggestedEmotions == ["Stress", "Hope"])
        #expect(viewModel.draft.reflectionSummary == "You felt pressure but kept going.")
        #expect(viewModel.draft.supportSuggestion?.title == "Breathing Break")
        #expect(viewModel.draft.revealedEmotions == ["Stress", "Hope"])
    }

    @MainActor
    @Test
    func analyzeEntryStoresFeedbackOnFailure() async {
        let store = MockMoodJournalStore()
        let analyzer = MockMoodJournalAnalyzer(
            analyzeHandler: { _ in throw MockError(message: "Analysis failed") }
        )
        let viewModel = MoodJournalViewModel(store: store, analyzer: analyzer, voiceJournalTranscriber: MockVoiceJournalTranscriber())
        viewModel.draft.inputText = "Today felt heavy"

        await viewModel.analyzeEntry()

        #expect(viewModel.draft.feedbackMessage == "Analysis failed")
    }

    @MainActor
    @Test
    func saveEntryWritesToStoreAndResetsDraft() {
        let store = MockMoodJournalStore()
        let viewModel = MoodJournalViewModel(store: store, analyzer: MockMoodJournalAnalyzer(), voiceJournalTranscriber: MockVoiceJournalTranscriber())
        viewModel.draft.inputText = "Journal"
        viewModel.draft.suggestedEmotions = ["Stress", "Calm"]
        viewModel.draft.selectedEmotions = ["Calm"]
        viewModel.draft.reflectionSummary = "Summary"
        viewModel.draft.supportSuggestion = SupportSuggestion(title: "Rest", detail: "Pause", symbol: "bed.double.fill")

        viewModel.saveEntry()

        #expect(store.addedEntries.count == 1)
        #expect(store.addedEntries[0].selectedEmotions == ["Calm"])
        #expect(viewModel.draft.inputText.isEmpty)
        #expect(viewModel.draft.feedbackMessage == "Entry saved.")
    }

    @MainActor
    @Test
    func toggleVoiceEntryAppendsTranscriptFromCompletion() async {
        let store = MockMoodJournalStore()
        let transcriber = MockVoiceJournalTranscriber()
        let viewModel = MoodJournalViewModel(store: store, analyzer: MockMoodJournalAnalyzer(), voiceJournalTranscriber: transcriber)

        await viewModel.toggleVoiceEntry()
        #expect(viewModel.isRecordingVoiceEntry)

        await transcriber.completion?(.success("Spoken entry"))

        #expect(!viewModel.isRecordingVoiceEntry)
        #expect(viewModel.draft.inputText == "Spoken entry")
    }
}
