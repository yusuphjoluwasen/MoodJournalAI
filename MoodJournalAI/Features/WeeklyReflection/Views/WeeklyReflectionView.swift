//
//  WeeklyReflectionView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI
import Charts

struct WeeklyReflectionView: View {
    let store: MoodJournalStore

    @State private var viewModel: WeeklyReflectionViewModel

    init(store: MoodJournalStore) {
        self.store = store
        _viewModel = State(initialValue: WeeklyReflectionViewModel(store: store))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                headerCard

                if viewModel.hasWeeklyEntries {
                    actionRow

                    if viewModel.isGenerating {
                        loadingCard
                    } else {
                        if let errorState = viewModel.errorState {
                            errorCard(errorState)
                        }

                        if !store.weeklyMoodTrends.isEmpty {
                            moodTrendsCard
                        }

                        if !viewModel.recap.isEmpty {
                            reflectionCard(
                                title: "Weekly Recap",
                                subtitle: "A short look back at how your week felt overall.",
                                text: viewModel.recap,
                                colors: [Color(red: 0.19, green: 0.42, blue: 0.74), Color(red: 0.51, green: 0.28, blue: 0.73)]
                            )
                        }

                        if !viewModel.insight.isEmpty {
                            reflectionCard(
                                title: "Weekly Reflection",
                                subtitle: "A gentle reflection on the patterns in the entries you saved this week.",
                                text: viewModel.insight,
                                colors: [Color(red: 0.86, green: 0.43, blue: 0.29), Color(red: 0.71, green: 0.55, blue: 0.21)]
                            )
                        }
                    }
                } else {
                    emptyCard
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
        .navigationTitle("Weekly Reflection")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.generateReflectionsIfNeeded()
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Reflection")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Read your weekly summary and reflection here, without crowding the Home screen.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.27, blue: 0.60), Color(red: 0.88, green: 0.45, blue: 0.27)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            Button {
                Task {
                    await viewModel.generateReflections()
                }
            } label: {
                HStack(spacing: 8) {
                    if viewModel.isGenerating {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(viewModel.isGenerating ? "Refreshing..." : "Refresh")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    viewModel.isGenerating ? Color(red: 0.48, green: 0.63, blue: 0.84) : Color(red: 0.18, green: 0.39, blue: 0.72),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isGenerating)

            if viewModel.exportText.isEmpty {
                Label("Export", systemImage: "square.and.arrow.up")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.gray.opacity(0.22), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .foregroundStyle(.secondary)
            } else {
                ShareLink(item: viewModel.exportText) {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .foregroundStyle(Color(red: 0.17, green: 0.28, blue: 0.59))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var loadingCard: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.1)
            Text("Putting together your weekly reflection...")
                .font(.headline)
            Text("This page gives you a calm place to look back on your week.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(26)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var moodTrendsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Mood Trends")
                .font(.title3.bold())

            Text("A quick look at the moods you confirmed most often this week.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Chart(store.weeklyMoodTrends) { item in
                BarMark(
                    x: .value("Mood", item.emotion),
                    y: .value("Count", item.count)
                )
                .cornerRadius(8)
                .foregroundStyle(
                    .linearGradient(
                        colors: [Color(red: 0.18, green: 0.39, blue: 0.72), Color(red: 0.86, green: 0.43, blue: 0.29)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let emotion = value.as(String.self) {
                            Text(MoodEmojiMapper.emoji(for: emotion))
                                .font(.caption)
                        }
                    }
                }
            }
            .chartPlotStyle { plot in
                plot
                    .background(Color(red: 0.96, green: 0.97, blue: 0.99))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No weekly reflection yet")
                .font(.title3.bold())
            Text("Save a few entries this week to unlock your summary, reflection, and export options.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private func errorCard(_ errorState: ReflectionErrorState) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(errorState.title, systemImage: "exclamationmark.bubble.fill")
                .font(.headline)
                .foregroundStyle(Color(red: 0.56, green: 0.24, blue: 0.16))

            Text(errorState.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color(red: 0.86, green: 0.78, blue: 0.72), lineWidth: 1)
        )
    }

    private func reflectionCard(title: String, subtitle: String, text: String, colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
            Text(text)
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
    }
}

#Preview {
    NavigationStack {
        WeeklyReflectionView(store: MoodJournalStore())
    }
}
