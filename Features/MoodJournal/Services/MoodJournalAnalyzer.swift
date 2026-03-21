//
//  MoodJournalAnalyzer.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import FoundationModels

enum MoodJournalAnalyzerError: LocalizedError {
    case modelUnavailable(String)

    var errorDescription: String? {
        switch self {
        case .modelUnavailable(let details):
            return "AI features are not available right now on this device: \(details)"
        }
    }
}

struct MoodJournalAnalyzer {
    let emotionModel = SystemLanguageModel(useCase: .contentTagging)
    let summaryModel = SystemLanguageModel.default
}
