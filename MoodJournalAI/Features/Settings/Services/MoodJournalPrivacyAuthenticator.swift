//
//  MoodJournalPrivacyAuthenticator.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import LocalAuthentication

enum MoodJournalPrivacyAuthenticatorError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Face ID, Touch ID, or device passcode is not available on this device."
        }
    }
}

struct MoodJournalPrivacyAuthenticator {
    func authenticate(reason: String) async throws {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            throw MoodJournalPrivacyAuthenticatorError.unavailable
        }

        try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason)
    }
}
