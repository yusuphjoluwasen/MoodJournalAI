//
//  MoodJournalAnalyzer+Support.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation

extension MoodJournalAnalyzer {
    func uniqueEmotionLabels(from emotions: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []

        for emotion in emotions {
            let trimmed = emotion.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            let key = trimmed.lowercased()
            guard !seen.contains(key) else { continue }

            seen.insert(key)
            result.append(trimmed)
        }

        return result
    }

    func supportSuggestion(for emotions: [String]) -> SupportSuggestion {
        let combined = emotions.joined(separator: " ").lowercased()

        if combined.contains("stress") || combined.contains("anx") || combined.contains("worr") {
            return SupportSuggestion(
                title: "Breathing Break",
                detail: "Step away for one minute and take five slow breaths. A short pause can help your body settle.",
                symbol: "wind"
            )
        }

        if combined.contains("sad") || combined.contains("lonely") || combined.contains("down") {
            return SupportSuggestion(
                title: "Text Someone",
                detail: "Send a simple message to someone you trust. Even a small moment of connection can help you feel less alone.",
                symbol: "message.fill"
            )
        }

        if combined.contains("ang") || combined.contains("frustrat") || combined.contains("agitat") {
            return SupportSuggestion(
                title: "Short Walk",
                detail: "Change your environment for a few minutes. A brief walk can help release built-up tension.",
                symbol: "figure.walk"
            )
        }

        if combined.contains("exhaust") || combined.contains("drain") || combined.contains("overwhelm") {
            return SupportSuggestion(
                title: "Rest",
                detail: "Give yourself permission to pause instead of pushing through. Rest can be a useful next step, not a setback.",
                symbol: "bed.double.fill"
            )
        }

        return SupportSuggestion(
            title: "Drink Water",
            detail: "Take a minute to hydrate and check in with your body. Small physical resets can support emotional clarity too.",
            symbol: "drop.fill"
        )
    }
}
