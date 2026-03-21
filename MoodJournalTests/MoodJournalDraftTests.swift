import Foundation
import Testing
@testable import MoodJournal

struct MoodJournalDraftTests {
    @Test
    func prepareForAnalysisClearsTransientState() {
        var draft = MoodJournalDraft()
        draft.suggestedEmotions = ["Calm"]
        draft.selectedEmotions = ["Calm"]
        draft.reflectionSummary = "Summary"
        draft.revealedEmotions = ["Calm"]
        draft.feedbackMessage = "Saved"
        draft.supportSuggestion = SupportSuggestion(title: "Rest", detail: "Pause", symbol: "bed.double.fill")

        draft.prepareForAnalysis()

        #expect(draft.suggestedEmotions.isEmpty)
        #expect(draft.selectedEmotions.isEmpty)
        #expect(draft.reflectionSummary.isEmpty)
        #expect(draft.revealedEmotions.isEmpty)
        #expect(draft.feedbackMessage.isEmpty)
        #expect(draft.supportSuggestion == nil)
    }

    @Test
    func orderedSelectedEmotionsPreservesSuggestionOrder() {
        var draft = MoodJournalDraft()
        draft.suggestedEmotions = ["Stress", "Calm", "Joy"]
        draft.selectedEmotions = ["Joy", "Stress"]

        #expect(draft.orderedSelectedEmotions() == ["Stress", "Joy"])
    }

    @Test
    func appendVoiceTranscriptAppendsOnNewLineWhenNeeded() {
        var draft = MoodJournalDraft()
        draft.appendVoiceTranscript("First thought")
        draft.appendVoiceTranscript("Second thought")

        #expect(draft.inputText == "First thought\nSecond thought")
    }

    @Test
    func markSavedResetsDraftAndSetsFeedback() {
        var draft = MoodJournalDraft()
        draft.inputText = "Entry"
        draft.suggestedEmotions = ["Calm"]
        draft.selectedEmotions = ["Calm"]
        draft.reflectionSummary = "Summary"
        draft.revealedEmotions = ["Calm"]
        draft.supportSuggestion = SupportSuggestion(title: "Rest", detail: "Pause", symbol: "bed.double.fill")

        draft.markSaved()

        #expect(draft.inputText.isEmpty)
        #expect(draft.suggestedEmotions.isEmpty)
        #expect(draft.selectedEmotions.isEmpty)
        #expect(draft.reflectionSummary.isEmpty)
        #expect(draft.revealedEmotions.isEmpty)
        #expect(draft.supportSuggestion == nil)
        #expect(draft.feedbackMessage == "Entry saved.")
    }
}
