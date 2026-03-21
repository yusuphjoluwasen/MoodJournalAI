//
//  SelfCareTipsViewModel.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class SelfCareTipsViewModel {
    var tip: SelfCareTip?
    var isLoading = false
    var errorState: SelfCareErrorState?
    var refreshID = UUID()

    private let analyzer: MoodJournalAnalyzing

    init(analyzer: MoodJournalAnalyzing = MoodJournalAnalyzer()) {
        self.analyzer = analyzer
    }

    func refresh() {
        guard !isLoading else { return }
        refreshID = UUID()
    }

    func generateTip() async {
        isLoading = true
        errorState = nil
        defer { isLoading = false }

        do {
            tip = try await analyzer.selfCareTip()
        } catch {
            tip = nil
            errorState = SelfCareErrorState(error: error)
        }
    }
}

struct SelfCareErrorState {
    let title: String
    let message: String

    init(error: Error) {
        if let analyzerError = error as? MoodJournalAnalyzerError {
            switch analyzerError {
            case .modelUnavailable:
                title = "Self-care tips are unavailable"
                message = "This phone can’t create self-care tips right now. Try again later, or keep using the rest of the app as usual."
            }
        } else {
            title = "Couldn’t load a tip"
            message = "Something interrupted tip generation. Tap Next Tip to try again."
        }
    }
}
