//
//  WeeklyReflectionViewModel.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class WeeklyReflectionViewModel {
    var recap = ""
    var insight = ""
    var errorState: ReflectionErrorState?
    var isGenerating = false

    private let store: MoodJournalStoreProviding
    private let analyzer: MoodJournalAnalyzing

    convenience init(store: MoodJournalStoreProviding) {
        self.init(
            store: store,
            analyzer: MoodJournalAnalyzer()
        )
    }

    init(
        store: MoodJournalStoreProviding,
        analyzer: MoodJournalAnalyzing
    ) {
        self.store = store
        self.analyzer = analyzer
    }

    var hasWeeklyEntries: Bool {
        !store.weeklyEntries.isEmpty
    }

    var exportText: String {
        guard !recap.isEmpty || !insight.isEmpty else { return "" }
        return store.weeklyExportText(recap: recap, insight: insight)
    }

    func generateReflectionsIfNeeded() async {
        guard hasWeeklyEntries, recap.isEmpty, insight.isEmpty else { return }
        await generateReflections()
    }

    func generateReflections() async {
        guard hasWeeklyEntries else { return }

        isGenerating = true
        errorState = nil
        defer { isGenerating = false }

        do {
            recap = try await analyzer.weeklyRecap(for: store.weeklyEntries)
            insight = try await analyzer.weeklyHealthInsight(for: store.weeklyEntries)
        } catch {
            recap = ""
            insight = ""
            errorState = ReflectionErrorState(error: error)
        }
    }
}

struct ReflectionErrorState {
    let title: String
    let message: String

    init(error: Error) {
        if let analyzerError = error as? MoodJournalAnalyzerError {
            switch analyzerError {
            case .modelUnavailable:
                title = "Weekly reflection is unavailable"
                message = "This phone can’t create a weekly reflection right now. You can still review your saved entries and mood trends, then try again later."
            }
        } else {
            title = "Couldn’t generate your reflection"
            message = "Something went wrong while building this week’s recap. Pull to refresh or tap Refresh to try again."
        }
    }
}
