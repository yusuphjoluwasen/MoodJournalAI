//
//  MoodJournalAnalyzer+SelfCare.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import FoundationModels

extension MoodJournalAnalyzer {
    func selfCareTip() async throws -> SelfCareTip {
        guard summaryModel.isAvailable else {
            throw MoodJournalAnalyzerError.modelUnavailable(String(describing: summaryModel.availability))
        }

        let session = LanguageModelSession(model: summaryModel)
        let prompts = [
            "Generate one short self-care tip for emotional reset. Return a title under 4 words and 1 or 2 short sentences under 36 words total.",
            "Generate one short self-care tip for stressful days. Return a title under 4 words and 1 or 2 short sentences under 36 words total.",
            "Generate one short self-care tip about slowing down and checking in. Return a title under 4 words and 1 or 2 short sentences under 36 words total.",
            "Generate one short self-care tip for feeling overwhelmed. Return a title under 4 words and 1 or 2 short sentences under 36 words total.",
            "Generate one short self-care tip for rebuilding energy. Return a title under 4 words and 1 or 2 short sentences under 36 words total."
        ]

        let prompt = prompts.randomElement() ?? prompts[0]
        let response: SelfCareTipResponse = try await session.respond(
            to: prompt,
            generating: SelfCareTipResponse.self
        ).content

        return SelfCareTip(title: response.title, tip: response.tip)
    }
}
