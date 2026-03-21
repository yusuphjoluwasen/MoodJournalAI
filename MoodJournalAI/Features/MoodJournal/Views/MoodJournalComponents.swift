//
//  MoodJournalComponents.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct WeeklyOverviewCard: View {
    let overview: WeeklyMoodOverview
    let hasWeeklyReflection: Bool
    let openWeeklyReflection: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("This Week")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                Spacer()
            }

            HStack(spacing: 8) {
                MetricTile(title: "Entries", value: "\(overview.entriesCount)")
                MetricTile(title: "Current Streak", value: "\(overview.currentStreak)")
                MetricTile(title: "Longest", value: "\(overview.longestStreak)")
            }

            if overview.topEmotions.isEmpty {
                Text("Save an entry to start building your weekly mood summary.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Most Confirmed Moods")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))

                    ForEach(overview.topEmotions) { emotion in
                        HStack {
                            Text(MoodEmojiMapper.emoji(for: emotion.emotion))
                            Text(emotion.emotion)
                            Spacer()
                            Text("\(emotion.count)")
                                .foregroundStyle(.white.opacity(0.75))
                        }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    }
                }
            }

            Button(action: openWeeklyReflection) {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                    Text("Weekly Reflection")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(hasWeeklyReflection ? .white : .white.opacity(0.65))
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(.white.opacity(hasWeeklyReflection ? 0.12 : 0.08), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!hasWeeklyReflection)

        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.27, blue: 0.60), Color(red: 0.88, green: 0.45, blue: 0.27)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
    }
}

struct MetricTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .foregroundStyle(.white)
    }
}

struct EmotionSuggestionChip: View {
    let emotion: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(MoodEmojiMapper.emoji(for: emotion))
                Text(emotion.capitalized)
                    .font(.footnote.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ? Color(red: 0.94, green: 0.54, blue: 0.30) : Color.white,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.clear : Color.black.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(isSelected ? .white : .primary)
            .shadow(color: .black.opacity(isSelected ? 0.12 : 0.05), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
    }
}

struct MoodFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if title != "All" {
                    Text(MoodEmojiMapper.emoji(for: title))
                }
                Text(title)
                    .font(.caption.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(
                isSelected ? Color(red: 0.21, green: 0.48, blue: 0.86) : Color.white,
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.black.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct ReflectionCard: View {
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AI Reflection")
                .font(.headline)
            Text(summary)
                .font(.subheadline)
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
}

struct SupportSuggestionCard: View {
    let suggestion: SupportSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: suggestion.symbol)
                    .font(.headline)
                    .foregroundStyle(Color(red: 0.15, green: 0.51, blue: 0.42))
                    .frame(width: 36, height: 36)
                    .background(Color(red: 0.90, green: 0.98, blue: 0.95), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Text("Gentle Next Step")
                    .font(.headline)
            }

            Text(suggestion.title)
                .font(.title3.bold())
            Text(suggestion.detail)
                .font(.subheadline)
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
}

struct PrivacyLockCard: View {
    let isLocked: Bool
    let feedback: String
    let unlockAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Mood Journal Locked")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text("Use Face ID, Touch ID, or your device passcode to unlock your journal.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                }
            }

            Button(action: unlockAction) {
                Text(isLocked ? "Unlock Journal" : "Unlocked")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .foregroundStyle(Color(red: 0.17, green: 0.28, blue: 0.59))
            }
            .buttonStyle(.plain)
            .disabled(!isLocked)

            if !feedback.isEmpty {
                Text(feedback)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color(red: 0.17, green: 0.28, blue: 0.59), Color(red: 0.45, green: 0.24, blue: 0.63)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(entry.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(entry.selectedEmotions.count == 1 ? "1 mood saved" : "\(entry.selectedEmotions.count) moods saved")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(entry.text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(3)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(entry.selectedEmotions, id: \.self) { emotion in
                        HStack(spacing: 6) {
                            Text(MoodEmojiMapper.emoji(for: emotion))
                            Text(emotion.capitalized)
                        }
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.98, green: 0.94, blue: 0.89), in: Capsule())
                    }
                }
            }

            Text(entry.reflectionSummary)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            if let supportSuggestion = entry.supportSuggestion {
                HStack(spacing: 8) {
                    Image(systemName: supportSuggestion.symbol)
                    Text(supportSuggestion.title)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.15, green: 0.51, blue: 0.42))
            }
        }
        .padding(18)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}
