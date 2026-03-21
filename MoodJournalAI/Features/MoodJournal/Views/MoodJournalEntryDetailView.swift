//
//  MoodJournalEntryDetailView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct MoodJournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss

    let store: MoodJournalStore
    let entry: JournalEntry
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                textCard
                emotionSection(
                    title: "Confirmed Moods",
                    subtitle: "The moods you selected to save for this entry.",
                    emotions: entry.selectedEmotions,
                    accentColor: Color(red: 0.94, green: 0.54, blue: 0.30)
                )
                emotionSection(
                    title: "AI Suggestions",
                    subtitle: "The full set of moods AI suggested for this entry.",
                    emotions: entry.suggestedEmotions,
                    accentColor: Color(red: 0.20, green: 0.46, blue: 0.81)
                )
                if let supportSuggestion = entry.supportSuggestion {
                    SupportSuggestionCard(suggestion: supportSuggestion)
                }
                ReflectionCard(summary: entry.reflectionSummary)
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
        .navigationTitle("Entry Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Delete Entry?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                store.deleteEntry(id: entry.id)
                dismiss()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This journal entry will be removed from your history and weekly summaries.")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(entry.createdAt.formatted(date: .complete, time: .shortened))
                .font(.headline)
                .foregroundStyle(.white)

            Text(entry.selectedEmotions.isEmpty ? "No moods selected" : "\(entry.selectedEmotions.count) moods confirmed")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.39, blue: 0.72), Color(red: 0.55, green: 0.28, blue: 0.74)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
    }

    private var textCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Journal Entry")
                .font(.headline)
            Text(entry.text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    private func emotionSection(
        title: String,
        subtitle: String,
        emotions: [String],
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if emotions.isEmpty {
                Text("No moods available for this section.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(emotions, id: \.self) { emotion in
                        HStack(spacing: 8) {
                            Text(MoodEmojiMapper.emoji(for: emotion))
                            Text(emotion.capitalized)
                                .font(.subheadline.weight(.semibold))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        MoodJournalEntryDetailView(
            store: MoodJournalStore(),
            entry: JournalEntry(
                id: UUID(),
                text: "I had a long day at work but I still feel hopeful about tomorrow.",
                createdAt: .now,
                suggestedEmotions: ["stressed", "tired", "hopeful", "relieved"],
                selectedEmotions: ["stressed", "hopeful"],
                reflectionSummary: "You seem stretched by the day, but there is still a clear sense of optimism. That hopefulness gives this entry a steady, grounded tone.",
                supportSuggestion: SupportSuggestion(
                    title: "Breathing Break",
                    detail: "Step away for one minute and take five slow breaths. A short pause can help your body settle.",
                    symbol: "wind"
                )
            )
        )
    }
}
