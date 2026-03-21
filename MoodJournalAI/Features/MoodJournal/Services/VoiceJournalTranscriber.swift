//
//  VoiceJournalTranscriber.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import AVFoundation
import Foundation
import Speech

enum VoiceJournalTranscriberError: LocalizedError {
    case speechRecognitionUnavailable
    case speechRecognitionDenied
    case microphoneDenied
    case recognizerUnavailable
    case alreadyRecording
    case failedToStart

    var errorDescription: String? {
        switch self {
        case .speechRecognitionUnavailable:
            return "Speech recognition is not available on this device right now."
        case .speechRecognitionDenied:
            return "Speech recognition permission is turned off for this app."
        case .microphoneDenied:
            return "Microphone access is turned off for this app."
        case .recognizerUnavailable:
            return "Voice journaling is not available for your current language."
        case .alreadyRecording:
            return "A voice journal recording is already in progress."
        case .failedToStart:
            return "Voice journaling could not start."
        }
    }
}

final class VoiceJournalTranscriber {
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()

    private var speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var onCompletion: (@MainActor (Result<String, Error>) -> Void)?
    private var latestTranscript = ""
    private var stopRequested = false
    private(set) var isRecording = false

    deinit {
        stopTranscribing()
    }

    func startTranscribing(
        locale: Locale = .current,
        onCompletion: @escaping @MainActor (Result<String, Error>) -> Void
    ) async throws {
        guard !isRecording else {
            throw VoiceJournalTranscriberError.alreadyRecording
        }

        try await requestPermissions()

        guard let recognizer = SFSpeechRecognizer(locale: locale) ?? SFSpeechRecognizer(),
              recognizer.isAvailable else {
            throw VoiceJournalTranscriberError.recognizerUnavailable
        }

        self.speechRecognizer = recognizer
        self.onCompletion = onCompletion
        self.latestTranscript = ""
        self.stopRequested = false

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if #available(iOS 18.0, *) {
            request.addsPunctuation = true
        }
        recognitionRequest = request

        do {
            try configureAudioSession()
        } catch {
            cleanup()
            throw VoiceJournalTranscriberError.failedToStart
        }

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            cleanup()
            throw VoiceJournalTranscriberError.failedToStart
        }

        isRecording = true

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                self.latestTranscript = result.bestTranscription.formattedString

                if result.isFinal {
                    self.finish(with: .success(self.latestTranscript))
                }
            } else if let error {
                if self.stopRequested {
                    self.finish(with: .success(self.latestTranscript))
                } else {
                    self.finish(with: .failure(error))
                }
            }
        }
    }

    func stopTranscribing() {
        guard isRecording else { return }
        stopRequested = true
        isRecording = false
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
    }

    private func requestPermissions() async throws {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        switch speechStatus {
        case .authorized:
            break
        case .denied, .restricted:
            throw VoiceJournalTranscriberError.speechRecognitionDenied
        case .notDetermined:
            throw VoiceJournalTranscriberError.speechRecognitionUnavailable
        @unknown default:
            throw VoiceJournalTranscriberError.speechRecognitionUnavailable
        }

        let microphoneGranted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        guard microphoneGranted else {
            throw VoiceJournalTranscriberError.microphoneDenied
        }
    }

    private func configureAudioSession() throws {
        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func finish(with result: Result<String, Error>?) {
        let completion = onCompletion

        cleanup()

        guard let result else { return }

        Task { @MainActor in
            completion?(result)
        }
    }

    private func cleanup() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        onCompletion = nil
        latestTranscript = ""
        stopRequested = false
        isRecording = false

        try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    }
}
