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
        case .assetsUnavailable(let context):
            return "Model assets are unavailable right now. \(context.debugDescription)"
        case .decodingFailure(let context):
            return "The model returned something the app could not read. \(context.debugDescription)"
        case .exceededContextWindowSize(let context):
            return "That request was too large for the model to process. \(context.debugDescription)"
        case .guardrailViolation(let context):
            return "The request could not be completed because of a built-in safety rule. \(context.debugDescription)"
        case .rateLimited(let context):
            return "The model is busy right now. Please try again in a moment. \(context.debugDescription)"
        case .refusal(_, let context):
            return "The model declined that request. \(context.debugDescription)"
        case .concurrentRequests(let context):
            return "Another model request is already running. \(context.debugDescription)"
        case .unsupportedGuide(let context):
            return "This request uses a model feature that is not supported here. \(context.debugDescription)"
        case .unsupportedLanguageOrLocale(let context):
            return "This language or region is not supported for the current model request. \(context.debugDescription)"
        @unknown default:
            return "The model hit an unexpected error. \(error.failureReason ?? error.localizedDescription)"
        }
    }

    static func message(for error: LanguageModelSession.ToolCallError) -> String {
        "A model tool call failed. \(error.errorDescription ?? error.localizedDescription)"
    }

    static func message(for error: Error) -> String {
        if let generationError = error as? LanguageModelSession.GenerationError {
            return message(for: generationError)
        }

        if let toolCallError = error as? LanguageModelSession.ToolCallError {
            return message(for: toolCallError)
        }

        return error.localizedDescription
    }
}
