//
//  MoodJournalErrorSupport.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import LocalAuthentication
import OSLog

enum MoodJournalErrorLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "MoodJournalAI"

    static let app = Logger(subsystem: subsystem, category: "App")
    static let journal = Logger(subsystem: subsystem, category: "Journal")
    static let settings = Logger(subsystem: subsystem, category: "Settings")
}

enum MoodJournalUserErrorMapper {
    static func journalMessage(for error: Error) -> String {
        if let analyzerError = error as? MoodJournalAnalyzerError {
            switch analyzerError {
            case .modelUnavailable:
                return "This phone can’t analyze journal entries right now. You can keep writing and try again later."
            }
        }

        return MoodJournalModelErrorMapper.message(for: error)
    }

    static func privacyMessage(for error: Error) -> String {
        if error is MoodJournalPrivacyAuthenticatorError {
            return "Face ID, Touch ID, or your device passcode is not available on this device."
        }

        if let laError = error as? LAError {
            switch laError.code {
            case .userCancel, .systemCancel, .appCancel:
                return "Authentication was canceled. Try again when you're ready."
            case .authenticationFailed:
                return "Your identity couldn’t be confirmed. Please try again."
            case .biometryNotAvailable, .biometryNotEnrolled, .passcodeNotSet:
                return "Face ID, Touch ID, or your device passcode is not available on this device."
            default:
                return "Authentication could not be completed right now. Please try again."
            }
        }

        return "Authentication could not be completed right now. Please try again."
    }

    static func reminderMessage(for error: Error) -> String {
        if error is MoodJournalReminderSchedulerError {
            return "Notifications are turned off for this app. Turn them on in Settings to use daily reminders."
        }

        return "The daily reminder could not be updated right now. Please try again."
    }
}
