//
//  MoodJournalHistoryView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct MoodJournalHistoryView: View {
    enum HistoryMode: String, CaseIterable, Identifiable {
        case list = "List"
        case calendar = "Calendar"

        var id: String { rawValue }
    }

    let store: MoodJournalStore

    @State private var viewModel: MoodJournalHistoryViewModel

    init(store: MoodJournalStore) {
        self.store = store
        _viewModel = State(initialValue: MoodJournalHistoryViewModel(store: store))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                headerCard
                weeklyReflectionButton

                Picker("History Mode", selection: $viewModel.historyMode) {
                    ForEach(HistoryMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                switch viewModel.historyMode {
                case .list:
                    listSection
                case .calendar:
                    calendarSection
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
        .navigationDestination(isPresented: $viewModel.isShowingWeeklyReflection) {
            WeeklyReflectionView(store: store)
        }
        .onChange(of: store.entries) { _, _ in
            viewModel.refresh()
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Journal Library")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Search past entries, filter by mood, or jump to a specific day in the calendar.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color(red: 0.19, green: 0.42, blue: 0.74), Color(red: 0.51, green: 0.28, blue: 0.73)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
    }

    private var weeklyReflectionButton: some View {
        Button {
            guard viewModel.hasWeeklyReflection else { return }
            viewModel.isShowingWeeklyReflection = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "sparkles.rectangle.stack.fill")
                Text("Weekly Reflection")
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(viewModel.hasWeeklyReflection ? Color.white : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .padding(.horizontal, 18)
            .background(buttonBackground, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.hasWeeklyReflection)
        .accessibilityHint(viewModel.hasWeeklyReflection ? "Opens your weekly reflection." : "Available after you save entries this week.")
    }

    private var buttonBackground: AnyShapeStyle {
        if !viewModel.hasWeeklyReflection {
            return AnyShapeStyle(Color.gray.opacity(0.20))
        }

        return AnyShapeStyle(
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.39, blue: 0.72), Color(red: 0.51, green: 0.28, blue: 0.73)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }

    private var listSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField(
                    "Search entries, moods, or reflections",
                    text: Binding(
                        get: { viewModel.historySearchText },
                        set: { viewModel.updateSearchText($0) }
                    )
                )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .accessibilityLabel("Search journal history")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    MoodFilterChip(title: "All", isSelected: viewModel.selectedMoodFilter == nil) {
                        viewModel.updateSelectedMood(nil)
                    }

                    ForEach(viewModel.availableMoodOptions, id: \.self) { mood in
                        MoodFilterChip(title: mood, isSelected: viewModel.selectedMoodFilter == mood) {
                            viewModel.updateSelectedMood(viewModel.selectedMoodFilter == mood ? nil : mood)
                        }
                    }
                }
            }

            if store.entries.isEmpty {
                emptyCard("Your saved journal entries will appear here.")
            } else if viewModel.filteredEntries.isEmpty {
                emptyCard("No entries match your current search or mood filter.")
            } else {
                LazyVStack(alignment: .leading, spacing: 18) {
                    ForEach(viewModel.groupedHistoryEntries) { section in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(section.title)
                                .font(.headline)
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 2)

                            ForEach(section.entries) { entry in
                                NavigationLink {
                                    MoodJournalEntryDetailView(store: store, entry: entry)
                                } label: {
                                    JournalEntryCard(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    private var calendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                DatePicker(
                    "Select Day",
                    selection: Binding(
                        get: { viewModel.selectedHistoryDate },
                        set: { viewModel.updateSelectedHistoryDate($0) }
                    ),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(Color(red: 0.90, green: 0.42, blue: 0.28))

                HStack {
                    Text(viewModel.selectedHistoryDate.formatted(date: .complete, time: .omitted))
                        .font(.headline)
                    Spacer()
                    Text(viewModel.selectedDateEntries.isEmpty ? "No entries" : "\(viewModel.selectedDateEntries.count) entries")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(22)
            .background(
                LinearGradient(
                    colors: [Color.white, Color(red: 0.98, green: 0.94, blue: 0.90)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 28, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )

            if viewModel.selectedDateEntries.isEmpty {
                emptyCard("No entries were saved on this day.")
            } else {
                ForEach(viewModel.selectedDateEntries) { entry in
                    NavigationLink {
                        MoodJournalEntryDetailView(store: store, entry: entry)
                    } label: {
                        JournalEntryCard(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func emptyCard(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        MoodJournalHistoryView(store: MoodJournalStore())
    }
}
