//
//  MoodJournalView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct MoodJournalView: View {
    let store: MoodJournalStore
    let isLocked: Bool
    let unlockAction: () -> Void

    @FocusState private var isEntryEditorFocused: Bool
    @State private var viewModel: MoodJournalViewModel

    private let emotionGrid = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    init(store: MoodJournalStore, isLocked: Bool, unlockAction: @escaping () -> Void) {
        self.store = store
        self.isLocked = isLocked
        self.unlockAction = unlockAction
        _viewModel = State(initialValue: MoodJournalViewModel(store: store))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if isLocked {
                    PrivacyLockCard(
                        isLocked: isLocked,
                        feedback: "",
                        unlockAction: unlockAction
                    )
                } else {
                    unlockedContent
                }
            }
            .padding(16)
            .padding(.bottom, isLocked ? 0 : 88)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.95, blue: 0.91), Color(red: 0.95, green: 0.97, blue: 0.99)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationDestination(isPresented: $viewModel.isShowingWeeklyReflection) {
            WeeklyReflectionView(store: store)
        }
        .safeAreaInset(edge: .bottom) {
            if !isLocked {
                bottomActionBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(.ultraThinMaterial)
            }
        }
        .onDisappear {
            viewModel.stopVoiceEntryIfNeeded()
        }
        .navigationTitle("Mood Journal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var unlockedContent: some View {
        Group {
            WeeklyOverviewCard(
                overview: viewModel.weeklyOverview,
                hasWeeklyReflection: viewModel.hasWeeklyReflection,
                openWeeklyReflection: {
                    guard viewModel.hasWeeklyReflection else { return }
                    viewModel.isShowingWeeklyReflection = true
                }
            )

            composerCard
            if !viewModel.draft.reflectionSummary.isEmpty {
                ReflectionCard(summary: viewModel.draft.reflectionSummary)
            }

            if let supportSuggestion = viewModel.draft.supportSuggestion {
                SupportSuggestionCard(suggestion: supportSuggestion)
            }

            if !viewModel.draft.suggestedEmotions.isEmpty {
                suggestionSection
            }

            if !viewModel.draft.feedbackMessage.isEmpty {
                Text(viewModel.draft.feedbackMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(red: 0.10, green: 0.43, blue: 0.32))
                    .padding(.horizontal, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var composerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today’s Entry")
                .font(.title3.bold())

            Text("Write a quick reflection and confirm the moods that fit.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let voiceEntryErrorState = viewModel.voiceEntryErrorState {
                voiceEntryStatusCard(voiceEntryErrorState)
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.draft.inputText)
                    .focused($isEntryEditorFocused)
                    .frame(minHeight: 96)
                    .padding(.top, 12)
                    .padding(.leading, 12)
                    .padding(.bottom, 12)
                    .padding(.trailing, 52)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    .overlay(alignment: .bottomTrailing) {
                        voiceRecorderButton
                            .padding(10)
                    }
                    .accessibilityLabel("Journal entry")
                    .accessibilityHint("Write or dictate how you're feeling today.")

                if viewModel.draft.isInputEmpty {
                    Text(viewModel.isRecordingVoiceEntry ? "Listening..." : "Write or dictate how you're feeling today...")
                        .font(.body)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 20)
                        .padding(.leading, 18)
                        .allowsHitTesting(false)
                }
            }

            if viewModel.isRecordingVoiceEntry {
                Label("Recording in progress", systemImage: "waveform")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(red: 0.74, green: 0.27, blue: 0.27))
                    .accessibilityElement(children: .combine)
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var voiceRecorderButton: some View {
                Button {
                    Task {
                        isEntryEditorFocused = false
                        await viewModel.toggleVoiceEntry()
                    }
                } label: {
            Image(systemName: viewModel.isRecordingVoiceEntry ? "stop.fill" : "mic.fill")
                .font(.footnote.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(
                    viewModel.isRecordingVoiceEntry ? Color(red: 0.74, green: 0.27, blue: 0.27) : Color(red: 0.18, green: 0.39, blue: 0.72),
                    in: Circle()
                )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isAnalyzing)
        .accessibilityLabel(viewModel.isRecordingVoiceEntry ? "Stop voice entry" : "Start voice entry")
    }

    private func voiceEntryStatusCard(_ errorState: VoiceEntryErrorState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(errorState.title, systemImage: "waveform.badge.mic")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.56, green: 0.24, blue: 0.16))

            Text(errorState.message)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(red: 0.86, green: 0.78, blue: 0.72), lineWidth: 1)
        )
    }

    private var bottomActionBar: some View {
        HStack(spacing: 12) {
            if isEntryEditorFocused {
                Button("Done") {
                    isEntryEditorFocused = false
                }
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .foregroundStyle(Color(red: 0.18, green: 0.39, blue: 0.72))
            }

            analyzeButton
        }
    }

    private var analyzeButton: some View {
        Button {
            Task {
                isEntryEditorFocused = false
                await viewModel.analyzeEntry()
            }
        } label: {
            HStack {
                if viewModel.isAnalyzing {
                    ProgressView()
                        .tint(.white)
                }
                Text(viewModel.isAnalyzing ? "Analyzing..." : "Analyze Entry")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .background(
            LinearGradient(
                colors: [Color(red: 0.93, green: 0.51, blue: 0.28), Color(red: 0.90, green: 0.32, blue: 0.32)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .foregroundStyle(.white)
        .disabled(!viewModel.canAnalyze)
        .accessibilityHint("Analyzes your entry and suggests moods.")
    }

    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Mood Suggestions")
                        .font(.title3.bold())
                    Text("Tap the ones that feel right, then save your entry.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            LazyVGrid(columns: emotionGrid, spacing: 10) {
                ForEach(viewModel.draft.revealedEmotions, id: \.self) { emotion in
                    EmotionSuggestionChip(emotion: emotion, isSelected: viewModel.draft.selectedEmotions.contains(emotion)) {
                        withAnimation(.spring(duration: 0.28, bounce: 0.28)) {
                            viewModel.toggleSelection(for: emotion)
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }

            Button {
                viewModel.saveEntry()
                isEntryEditorFocused = false
            } label: {
                Text(viewModel.draft.selectedEmotions.isEmpty ? "Select a mood to save" : "Save to Journal")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
            .background(
                viewModel.draft.selectedEmotions.isEmpty ? Color.gray.opacity(0.25) : Color(red: 0.14, green: 0.50, blue: 0.39),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .foregroundStyle(viewModel.draft.selectedEmotions.isEmpty ? Color.secondary : Color.white)
            .disabled(!viewModel.canSave)
        }
        .padding(18)
        .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

}

#Preview {
    NavigationStack {
        MoodJournalView(store: MoodJournalStore(), isLocked: false, unlockAction: {})
    }
}
