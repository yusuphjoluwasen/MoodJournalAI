//
//  MoodJournalViewModel.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class MoodJournalViewModel {
    var draft = MoodJournalDraft()
    var isShowingWeeklyReflection = false
    var isAnalyzing = false
    var isRecordingVoiceEntry = false
    var voiceEntryErrorState: VoiceEntryErrorState?

    private let store: MoodJournalStoreProviding
    private let analyzer: MoodJournalAnalyzing
    private let voiceJournalTranscriber: VoiceJournalTranscribing

    init(
        store: MoodJournalStoreProviding,
        analyzer: MoodJournalAnalyzing = MoodJournalAnalyzer(),
        voiceJournalTranscriber: VoiceJournalTranscribing = VoiceJournalTranscriber()
    ) {
        self.store = store
        self.analyzer = analyzer
        self.voiceJournalTranscriber = voiceJournalTranscriber
    }

    var weeklyOverview: WeeklyMoodOverview {
        store.weeklyOverview
    }

    var weeklyEntries: [JournalEntry] {
        store.weeklyEntries
    }

    var hasWeeklyReflection: Bool {
        !weeklyEntries.isEmpty
    }

    var canAnalyze: Bool {
        !isAnalyzing && !isRecordingVoiceEntry && !draft.isInputEmpty
    }

    var canSave: Bool {
        !draft.selectedEmotions.isEmpty && !isRecordingVoiceEntry
    }

    func stopVoiceEntryIfNeeded() {
        guard isRecordingVoiceEntry else { return }
        voiceJournalTranscriber.stopTranscribing()
        isRecordingVoiceEntry = false
    }

    func analyzeEntry() async {
        guard !draft.isInputEmpty else { return }

        stopVoiceEntryIfNeeded()
        isAnalyzing = true
        draft.prepareForAnalysis()
        defer { isAnalyzing = false }

        do {
            let analysis = try await analyzer.analyze(text: draft.trimmedInput)
            draft.applyAnalysis(analysis)
            await animateSuggestions(analysis.suggestedEmotions)
        } catch {
            draft.feedbackMessage = error.localizedDescription
        }
    }

    func toggleSelection(for emotion: String) {
        draft.toggleSelection(for: emotion)
    }

    func saveEntry() {
        guard !draft.isInputEmpty, !draft.selectedEmotions.isEmpty else { return }

        stopVoiceEntryIfNeeded()
        store.addEntry(
            text: draft.trimmedInput,
            suggestedEmotions: draft.suggestedEmotions,
            selectedEmotions: draft.orderedSelectedEmotions(),
            reflectionSummary: draft.reflectionSummary,
            supportSuggestion: draft.supportSuggestion
        )
        draft.markSaved()
    }

    func toggleVoiceEntry() async {
        if isRecordingVoiceEntry {
            stopVoiceEntryIfNeeded()
            return
        }

        voiceEntryErrorState = nil

        do {
            try await voiceJournalTranscriber.startTranscribing(locale: .current) { [weak self] result in
                guard let self else { return }

                self.isRecordingVoiceEntry = false

                switch result {
                case .success(let transcript):
                    self.draft.appendVoiceTranscript(transcript)
                case .failure(let error):
                    self.voiceEntryErrorState = VoiceEntryErrorState(error: error)
                }
            }

            isRecordingVoiceEntry = true
        } catch {
            voiceEntryErrorState = VoiceEntryErrorState(error: error)
            isRecordingVoiceEntry = false
        }
    }

    private func animateSuggestions(_ emotions: [String]) async {
        draft.revealedEmotions = []

        for emotion in emotions {
            draft.revealedEmotions.append(emotion)
            try? await Task.sleep(for: .milliseconds(110))
        }
    }
}

struct VoiceEntryErrorState {
    let title: String
    let message: String

    init(error: Error) {
        if let transcriberError = error as? VoiceJournalTranscriberError {
            switch transcriberError {
            case .speechRecognitionDenied:
                title = "Turn on Speech Recognition"
                message = "Allow Speech Recognition in Settings for this app, then try voice journaling again."
            case .microphoneDenied:
                title = "Turn on Microphone Access"
                message = "Allow microphone access in Settings for this app so you can record a voice entry."
            case .recognizerUnavailable, .speechRecognitionUnavailable:
                title = "Voice entry is unavailable"
                message = "Speech transcription is not available on this device or for your current language right now."
            case .alreadyRecording:
                title = "Recording already in progress"
                message = "Stop the current voice entry before starting another one."
            case .failedToStart:
                title = "Couldn’t start voice entry"
                message = "Something interrupted recording setup. Try again in a moment."
            }
        } else {
            title = "Voice entry stopped"
            message = "Something interrupted transcription. You can keep typing or start another voice entry."
        }
    }
}
