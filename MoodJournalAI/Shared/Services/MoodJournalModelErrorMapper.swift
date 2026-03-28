//
//  MoodJournalModelErrorMapper.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import FoundationModels

enum MoodJournalModelErrorMapper {
    static func message(for error: LanguageModelSession.GenerationError) -> String {
        switch error {
        case .assetsUnavailable:
            return "AI features are not available right now on this device."
        case .decodingFailure:
            return "The app couldn’t understand the response. Please try again."
        case .exceededContextWindowSize:
            return "That entry is too long to analyze right now. Try shortening it and try again."
        case .guardrailViolation:
            return "That request couldn’t be completed. Try adjusting your wording and trying again."
        case .rateLimited:
            return "AI is busy right now. Please try again in a moment."
        case .refusal:
            return "That request couldn’t be completed. Please try again."
        case .concurrentRequests:
            return "Another AI request is already running. Please wait a moment and try again."
        case .unsupportedGuide:
            return "That AI feature isn’t available right now."
        case .unsupportedLanguageOrLocale:
            return "Your current language or region isn’t supported for this AI feature yet."
        @unknown default:
            return "Something went wrong with AI generation. Please try again."
        }
    }

    static func message(for error: LanguageModelSession.ToolCallError) -> String {
        "Something went wrong while preparing the AI response. Please try again."
    }

    static func message(for error: Error) -> String {
        if let generationError = error as? LanguageModelSession.GenerationError {
            return message(for: generationError)
        }

        if let toolCallError = error as? LanguageModelSession.ToolCallError {
            return message(for: toolCallError)
        }

        return "Something went wrong. Please try again."
    }
}
