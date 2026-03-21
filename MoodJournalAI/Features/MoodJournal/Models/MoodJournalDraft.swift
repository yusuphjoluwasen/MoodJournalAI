//
//  MoodJournalDraft.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation

struct MoodJournalDraft {
    var inputText = ""
    var suggestedEmotions: [String] = []
    var selectedEmotions = Set<String>()
    var reflectionSummary = ""
    var revealedEmotions: [String] = []
    var feedbackMessage = ""
    var supportSuggestion: SupportSuggestion?

    var trimmedInput: String {
        inputText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isInputEmpty: Bool {
        trimmedInput.isEmpty
    }

    mutating func prepareForAnalysis() {
        feedbackMessage = ""
        suggestedEmotions = []
        selectedEmotions = []
        reflectionSummary = ""
        supportSuggestion = nil
        revealedEmotions = []
    }

    mutating func applyAnalysis(_ result: MoodJournalAnalysisResult) {
        suggestedEmotions = result.suggestedEmotions
        reflectionSummary = result.reflectionSummary
        supportSuggestion = result.supportSuggestion
    }

    mutating func toggleSelection(for emotion: String) {
        if selectedEmotions.contains(emotion) {
            selectedEmotions.remove(emotion)
        } else {
            selectedEmotions.insert(emotion)
        }
    }

    func orderedSelectedEmotions() -> [String] {
        suggestedEmotions.filter { selectedEmotions.contains($0) }
    }

    mutating func appendVoiceTranscript(_ transcript: String) {
        let trimmedTranscript = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTranscript.isEmpty else { return }

        if isInputEmpty {
            inputText = trimmedTranscript
        } else {
            inputText += "\n" + trimmedTranscript
        }
    }

    mutating func markSaved() {
        inputText = ""
        suggestedEmotions = []
        selectedEmotions = []
        reflectionSummary = ""
        supportSuggestion = nil
        revealedEmotions = []
        feedbackMessage = "Entry saved."
    }
}
