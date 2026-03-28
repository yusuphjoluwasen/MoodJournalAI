//
//  MoodJournalTheme.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

enum MoodJournalTheme {
    static let canvas = Color(uiColor: .systemBackground)
    static let canvasSecondary = Color(uiColor: .secondarySystemBackground)
    static let surface = Color(uiColor: .secondarySystemBackground)
    static let surfaceElevated = Color(uiColor: .systemBackground)
    static let surfaceTertiary = Color(uiColor: .tertiarySystemBackground)
    static let border = Color(uiColor: .separator).opacity(0.35)
    static let success = Color(uiColor: .systemGreen)
    static let warning = Color(uiColor: .systemOrange)
    static let error = Color(uiColor: .systemRed)
    static let accentBlue = Color(uiColor: .systemBlue)
    static let accentPurple = Color(uiColor: .systemPurple)
    static let accentOrange = Color(uiColor: .systemOrange)
    static let accentIndigo = Color(uiColor: .systemIndigo)
    static let accentMint = Color(uiColor: .systemMint)

    static func canvasGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(uiColor: .systemBackground), Color(uiColor: .secondarySystemBackground)]
                : [Color(uiColor: .systemGroupedBackground), Color(uiColor: .secondarySystemGroupedBackground)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func overviewGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(red: 0.16, green: 0.25, blue: 0.45), Color(red: 0.45, green: 0.25, blue: 0.32)]
                : [Color(red: 0.12, green: 0.27, blue: 0.60), Color(red: 0.88, green: 0.45, blue: 0.27)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func lockGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(red: 0.19, green: 0.26, blue: 0.43), Color(red: 0.30, green: 0.20, blue: 0.42)]
                : [Color(red: 0.17, green: 0.28, blue: 0.59), Color(red: 0.45, green: 0.24, blue: 0.63)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func primaryActionGradient(for colorScheme: ColorScheme) -> LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(red: 0.78, green: 0.40, blue: 0.24), Color(red: 0.68, green: 0.22, blue: 0.24)]
                : [Color(red: 0.93, green: 0.51, blue: 0.28), Color(red: 0.90, green: 0.32, blue: 0.32)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
