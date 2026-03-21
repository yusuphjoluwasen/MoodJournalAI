//
//  MoodJournalAnalyzer+JournalAnalysis.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import FoundationModels

extension MoodJournalAnalyzer {
    func analyze(text: String) async throws -> MoodJournalAnalysisResult {
        guard emotionModel.isAvailable else {
            throw MoodJournalAnalyzerError.modelUnavailable(String(describing: emotionModel.availability))
        }

        guard summaryModel.isAvailable else {
            throw MoodJournalAnalyzerError.modelUnavailable(String(describing: summaryModel.availability))
        }

        let emotionSession = LanguageModelSession(model: emotionModel)
        let emotionPrompt = "List the 4 most important emotions in this journal entry. Keep each emotion short and do not repeat emotions: \(text)"
        let emotionResponse: EmotionTagResponse = try await emotionSession.respond(
            to: emotionPrompt,
            generating: EmotionTagResponse.self
        ).content

        let summarySession = LanguageModelSession(model: summaryModel)
        let summaryPrompt = "Write a warm, supportive reflection about this journal entry in 2 short sentences. Avoid sounding clinical or preachy: \(text)"
        let summaryResponse: ReflectionSummaryResponse = try await summarySession.respond(
            to: summaryPrompt,
            generating: ReflectionSummaryResponse.self
        ).content

        let emotions = uniqueEmotionLabels(from: emotionResponse.emotions)

        return MoodJournalAnalysisResult(
            suggestedEmotions: emotions,
            reflectionSummary: summaryResponse.summary,
            supportSuggestion: supportSuggestion(for: emotions)
        )
    }
}
