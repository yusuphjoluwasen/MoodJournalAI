//
//  MoodJournalViewModel.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import Observation
import OSLog

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
    private let analytics: MoodJournalAnalyticsTracking
    private var feedbackDismissTask: Task<Void, Never>?

    convenience init(store: MoodJournalStoreProviding) {
        self.init(
            store: store,
            analyzer: MoodJournalAnalyzer(),
            voiceJournalTranscriber: VoiceJournalTranscriber(),
            analytics: MoodJournalAnalytics.shared
        )
    }

    init(
        store: MoodJournalStoreProviding,
        analyzer: MoodJournalAnalyzing,
        voiceJournalTranscriber: VoiceJournalTranscribing,
        analytics: MoodJournalAnalyticsTracking? = nil
    ) {
        self.store = store
        self.analyzer = analyzer
        self.voiceJournalTranscriber = voiceJournalTranscriber
        self.analytics = analytics ?? MoodJournalAnalytics.shared
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
        analytics.track(.journalAnalyzeRequested, parameters: [:])
        defer { isAnalyzing = false }

        do {
            let analysis = try await analyzer.analyze(text: draft.trimmedInput)
            draft.applyAnalysis(analysis)
            analytics.track(
                .journalAnalyzeSucceeded,
                parameters: ["suggested_emotion_count": String(analysis.suggestedEmotions.count)]
            )
            await animateSuggestions(analysis.suggestedEmotions)
        } catch {
            MoodJournalErrorLogger.journal.error("Journal analysis failed: \(String(describing: error), privacy: .public)")
            analytics.track(.journalAnalyzeFailed, parameters: [:])
            draft.feedbackMessage = MoodJournalUserErrorMapper.journalMessage(for: error)
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
        analytics.track(
            .journalEntrySaved,
            parameters: ["selected_emotion_count": String(draft.selectedEmotions.count)]
        )
        draft.markSaved()
        scheduleFeedbackDismissal()
    }

    func toggleVoiceEntry() async {
        if isRecordingVoiceEntry {
            stopVoiceEntryIfNeeded()
            return
        }

        voiceEntryErrorState = nil

        do {
            analytics.track(.voiceEntryStarted, parameters: [:])
            try await voiceJournalTranscriber.startTranscribing(locale: .current) { [weak self] result in
                guard let self else { return }

                self.isRecordingVoiceEntry = false

                switch result {
                case .success(let transcript):
                    self.analytics.track(
                        .voiceEntryCompleted,
                        parameters: ["transcript_empty": transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "true" : "false"]
                    )
                    self.draft.appendVoiceTranscript(transcript)
                case .failure(let error):
                    self.analytics.track(.voiceEntryFailed, parameters: [:])
                    self.voiceEntryErrorState = VoiceEntryErrorState(error: error)
                }
            }

            isRecordingVoiceEntry = true
        } catch {
            analytics.track(.voiceEntryFailed, parameters: [:])
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

    private func scheduleFeedbackDismissal() {
        feedbackDismissTask?.cancel()
        feedbackDismissTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2.5))
            guard !Task.isCancelled else { return }
            self?.draft.feedbackMessage = ""
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
