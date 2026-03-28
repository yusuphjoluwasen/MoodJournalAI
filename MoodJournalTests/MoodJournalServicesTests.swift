import Foundation
import Testing
@testable import MoodJournal

struct MoodJournalServicesTests {
    @Test
    func uniqueEmotionLabelsRemovesDuplicatesAndWhitespace() {
        let analyzer = MoodJournalAnalyzer()

        let result = analyzer.uniqueEmotionLabels(from: [" calm ", "Stress", "calm", "", "Stress"])

        #expect(result == ["calm", "Stress"])
    }

    @Test
    func supportSuggestionMatchesExpectedCategory() {
        let analyzer = MoodJournalAnalyzer()

        let stressSuggestion = analyzer.supportSuggestion(for: ["Stressed", "Worried"])
        let calmSuggestion = analyzer.supportSuggestion(for: ["Calm"])

        #expect(stressSuggestion.title == "Breathing Break")
        #expect(calmSuggestion.title == "Protect the Calm")
    }

    @Test
    func moodEmojiMapperReturnsExpectedEmoji() {
        #expect(MoodEmojiMapper.emoji(for: "stressed") == "😰")
        #expect(MoodEmojiMapper.emoji(for: "grateful") == "🙏")
        #expect(MoodEmojiMapper.emoji(for: "unknown") == "🙂")
    }

    @Test
    func voiceEntryErrorStateMapsKnownErrors() {
        let denied = VoiceEntryErrorState(error: VoiceJournalTranscriberError.microphoneDenied)
        let fallback = VoiceEntryErrorState(error: MockError(message: "Other"))

        #expect(denied.title == "Turn on Microphone Access")
        #expect(fallback.title == "Voice entry stopped")
    }
}
