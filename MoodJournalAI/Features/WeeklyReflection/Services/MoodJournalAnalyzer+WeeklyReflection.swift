//
//  MoodJournalAnalyzer+WeeklyReflection.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import FoundationModels

extension MoodJournalAnalyzer {
    func weeklyRecap(for entries: [JournalEntry]) async throws -> String {
        guard summaryModel.isAvailable else {
            throw MoodJournalAnalyzerError.modelUnavailable(String(describing: summaryModel.availability))
        }

        guard !entries.isEmpty else {
            return ""
        }

        let entryDigest = entries
            .sorted { $0.createdAt < $1.createdAt }
            .map {
                """
                Date: \($0.createdAt.formatted(date: .abbreviated, time: .omitted))
                Selected moods: \($0.selectedEmotions.joined(separator: ", "))
                Entry: \($0.text)
                """
            }
            .joined(separator: "\n\n")

        let session = LanguageModelSession(model: summaryModel)
        let prompt = """
        Write a supportive weekly recap of this person's journal entries in 2 short sentences. Mention the emotional patterns without sounding clinical, and focus on reflection rather than advice.

        \(entryDigest)
        """

        let response: WeeklyRecapResponse = try await session.respond(
            to: prompt,
            generating: WeeklyRecapResponse.self
        ).content

        return response.summary
    }

    func weeklyHealthInsight(for entries: [JournalEntry]) async throws -> String {
        guard summaryModel.isAvailable else {
            throw MoodJournalAnalyzerError.modelUnavailable(String(describing: summaryModel.availability))
        }

        guard !entries.isEmpty else {
            return ""
        }

        let digest = entries
            .sorted { $0.createdAt < $1.createdAt }
            .map {
                """
                Date: \($0.createdAt.formatted(date: .abbreviated, time: .omitted))
                Selected moods: \($0.selectedEmotions.joined(separator: ", "))
                Reflection summary: \($0.reflectionSummary)
                """
            }
            .joined(separator: "\n\n")

        let session = LanguageModelSession(model: summaryModel)
        let prompt = """
        Write a short wellbeing-style pattern insight based on these journal entries. Focus on mood patterns, rhythm, and reflection. Avoid diagnosis, treatment language, or certainty.

        \(digest)
        """

        let response: WeeklyInsightResponse = try await session.respond(
            to: prompt,
            generating: WeeklyInsightResponse.self
        ).content

        return response.insight
    }
}
