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
        for rule in supportSuggestionRules where rule.keywords.contains(where: combined.contains) {
            return rule.suggestion
        }

        return SupportSuggestion(
            title: "Drink Water",
            detail: "Take a minute to hydrate and check in with your body. Small physical resets can support emotional clarity too.",
            symbol: "drop.fill"
        )
    }
}

private struct SupportSuggestionRule {
    let keywords: [String]
    let suggestion: SupportSuggestion
}

private let supportSuggestionRules: [SupportSuggestionRule] = [
    SupportSuggestionRule(
        keywords: ["stress", "anx", "worr", "nerv", "tense", "panic"],
        suggestion: SupportSuggestion(
            title: "Breathing Break",
            detail: "Step away for one minute and take five slow breaths. A short pause can help your body settle.",
            symbol: "wind"
        )
    ),
    SupportSuggestionRule(
        keywords: ["sad", "lonely", "down", "isolat", "grief", "heartbroken"],
        suggestion: SupportSuggestion(
            title: "Text Someone",
            detail: "Send a simple message to someone you trust. Even a small moment of connection can help you feel less alone.",
            symbol: "message.fill"
        )
    ),
    SupportSuggestionRule(
        keywords: ["ang", "frustrat", "agitat", "irritat", "rage", "mad"],
        suggestion: SupportSuggestion(
            title: "Short Walk",
            detail: "Change your environment for a few minutes. A brief walk can help release built-up tension.",
            symbol: "figure.walk"
        )
    ),
    SupportSuggestionRule(
        keywords: ["exhaust", "drain", "overwhelm", "burnout", "fatigue", "tired"],
        suggestion: SupportSuggestion(
            title: "Rest",
            detail: "Give yourself permission to pause instead of pushing through. Rest can be a useful next step, not a setback.",
            symbol: "bed.double.fill"
        )
    ),
    SupportSuggestionRule(
        keywords: ["guilt", "asham", "regret", "embarrass", "self-conscious"],
        suggestion: SupportSuggestion(
            title: "Self-Kindness",
            detail: "Try speaking to yourself the way you would speak to someone you care about. A gentler tone can help the moment soften.",
            symbol: "heart.fill"
        )
    ),
    SupportSuggestionRule(
        keywords: ["confus", "uncertain", "doubt", "stuck", "puzzled"],
        suggestion: SupportSuggestion(
            title: "Clear One Step",
            detail: "Write down one small next step instead of solving everything at once. Clarity often starts with one simple choice.",
            symbol: "checklist"
        )
    ),
    SupportSuggestionRule(
        keywords: ["calm", "peace", "relax", "settled", "steady"],
        suggestion: SupportSuggestion(
            title: "Protect the Calm",
            detail: "Notice what is helping you feel steady right now. A small check-in can help you carry that feeling forward.",
            symbol: "leaf.fill"
        )
    ),
    SupportSuggestionRule(
        keywords: ["hope", "excite", "joy", "happy", "grateful", "proud"],
        suggestion: SupportSuggestion(
            title: "Savor the Moment",
            detail: "Take a second to name what is going well. Letting yourself notice it can help the feeling last a little longer.",
            symbol: "sun.max.fill"
        )
    )
]
