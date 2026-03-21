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

    @State private var isShowingWeeklyReflection = false
    @State private var inputText = ""
    @State private var suggestedEmotions: [String] = []
    @State private var selectedEmotions = Set<String>()
    @State private var reflectionSummary = ""
    @State private var revealedEmotions: [String] = []
    @State private var isAnalyzing = false
    @State private var feedbackMessage = ""
    @State private var supportSuggestion: SupportSuggestion?

    private let analyzer = MoodJournalAnalyzer()

    private let emotionGrid = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.95, blue: 0.91), Color(red: 0.95, green: 0.97, blue: 0.99)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationDestination(isPresented: $isShowingWeeklyReflection) {
            WeeklyReflectionView(store: store)
        }
        .navigationTitle("Mood Journal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var unlockedContent: some View {
        Group {
            WeeklyOverviewCard(
                overview: store.weeklyOverview,
                trends: store.weeklyMoodTrends,
                hasWeeklyReflection: !store.weeklyEntries.isEmpty,
                openWeeklyReflection: {
                    guard !store.weeklyEntries.isEmpty else { return }
                    isShowingWeeklyReflection = true
                }
            )

            composerCard
            if !reflectionSummary.isEmpty {
                ReflectionCard(summary: reflectionSummary)
            }

            if let supportSuggestion {
                SupportSuggestionCard(suggestion: supportSuggestion)
            }

            if !suggestedEmotions.isEmpty {
                suggestionSection
            }

            if !feedbackMessage.isEmpty {
                Text(feedbackMessage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(red: 0.10, green: 0.43, blue: 0.32))
                    .padding(.horizontal, 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var composerCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today’s Entry")
                .font(.title3.bold())

            Text("Write a quick reflection and let AI suggest moods you can confirm.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextEditor(text: $inputText)
                .frame(minHeight: 150)
                .padding(14)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )

            Button {
                Task {
                    await analyzeEntry()
                }
            } label: {
                HStack {
                    if isAnalyzing {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isAnalyzing ? "Analyzing..." : "Analyze Entry")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
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
            .disabled(isAnalyzing || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var suggestionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
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

            LazyVGrid(columns: emotionGrid, spacing: 12) {
                ForEach(revealedEmotions, id: \.self) { emotion in
                    EmotionSuggestionChip(emotion: emotion, isSelected: selectedEmotions.contains(emotion)) {
                        toggleSelection(for: emotion)
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.85).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }

            Button {
                saveEntry()
            } label: {
                Text(selectedEmotions.isEmpty ? "Select a mood to save" : "Save to Journal")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .background(
                selectedEmotions.isEmpty ? Color.gray.opacity(0.25) : Color(red: 0.14, green: 0.50, blue: 0.39),
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .foregroundStyle(selectedEmotions.isEmpty ? Color.secondary : Color.white)
            .disabled(selectedEmotions.isEmpty)
        }
        .padding(22)
        .background(Color.white.opacity(0.85), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    @MainActor
    private func analyzeEntry() async {
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else { return }

        isAnalyzing = true
        feedbackMessage = ""
        suggestedEmotions = []
        selectedEmotions = []
        reflectionSummary = ""
        supportSuggestion = nil
        revealedEmotions = []

        defer { isAnalyzing = false }

        do {
            let analysis = try await analyzer.analyze(text: trimmedInput)
            suggestedEmotions = analysis.suggestedEmotions
            reflectionSummary = analysis.reflectionSummary
            supportSuggestion = analysis.supportSuggestion
            await animateSuggestions(analysis.suggestedEmotions)
        } catch {
            feedbackMessage = error.localizedDescription
        }
    }

    @MainActor
    private func animateSuggestions(_ emotions: [String]) async {
        revealedEmotions = []

        for emotion in emotions {
            withAnimation(.spring(duration: 0.35, bounce: 0.35)) {
                revealedEmotions.append(emotion)
            }
            try? await Task.sleep(for: .milliseconds(110))
        }
    }

    private func toggleSelection(for emotion: String) {
        withAnimation(.spring(duration: 0.28, bounce: 0.28)) {
            if selectedEmotions.contains(emotion) {
                selectedEmotions.remove(emotion)
            } else {
                selectedEmotions.insert(emotion)
            }
        }
    }

    @MainActor
    private func saveEntry() {
        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty, !selectedEmotions.isEmpty else { return }

        let orderedSelections = suggestedEmotions.filter { selectedEmotions.contains($0) }
        store.addEntry(
            text: trimmedInput,
            suggestedEmotions: suggestedEmotions,
            selectedEmotions: orderedSelections,
            reflectionSummary: reflectionSummary,
            supportSuggestion: supportSuggestion
        )

        withAnimation(.spring(duration: 0.35, bounce: 0.2)) {
            inputText = ""
            suggestedEmotions = []
            selectedEmotions = []
            reflectionSummary = ""
            supportSuggestion = nil
            revealedEmotions = []
            feedbackMessage = "Entry saved."
        }
    }

}

#Preview {
    NavigationStack {
        MoodJournalView(store: MoodJournalStore(), isLocked: false, unlockAction: {})
    }
}
