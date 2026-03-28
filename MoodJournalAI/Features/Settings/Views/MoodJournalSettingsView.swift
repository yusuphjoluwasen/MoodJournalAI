//
//  MoodJournalSettingsView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct MoodJournalSettingsView: View {
    let store: MoodJournalStore
    let isLocked: Bool
    let privacyFeedback: String
    let unlockAction: () -> Void

    @State private var viewModel: MoodJournalSettingsViewModel

    init(store: MoodJournalStore, isLocked: Bool, privacyFeedback: String, unlockAction: @escaping () -> Void) {
        self.store = store
        self.isLocked = isLocked
        self.privacyFeedback = privacyFeedback
        self.unlockAction = unlockAction
        _viewModel = State(initialValue: MoodJournalSettingsViewModel(store: store))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                settingsHeader

                if isLocked {
                    PrivacyLockCard(
                        isLocked: isLocked,
                        feedback: privacyFeedback,
                        unlockAction: unlockAction
                    )
                } else {
                    reminderSection
                    privacySection
                    privacyInfoSection
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
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var settingsHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Journal Settings")
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text("Manage reminders, privacy, and how your journal works on this device.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            LinearGradient(
                colors: [Color(red: 0.16, green: 0.31, blue: 0.63), Color(red: 0.86, green: 0.43, blue: 0.29)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 28, style: .continuous)
        )
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Daily Reminder")
                .font(.title3.bold())

            VStack(alignment: .leading, spacing: 16) {
                Toggle(isOn: Binding(
                    get: { viewModel.reminderEnabled },
                    set: { newValue in
                        Task {
                            await viewModel.handleReminderToggle(newValue)
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Enable daily reminder")
                            .font(.headline)
                        Text("Get a private reminder on this device to check in and write.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(Color(red: 0.93, green: 0.51, blue: 0.28))

                if viewModel.reminderEnabled {
                    DatePicker(
                        "Reminder time",
                        selection: Binding(
                            get: { viewModel.reminderTime },
                            set: { newDate in
                                Task {
                                    await viewModel.updateReminderTime(newDate)
                                }
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                }

                if !viewModel.reminderFeedback.isEmpty {
                    Text(viewModel.reminderFeedback)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(22)
            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Privacy Lock")
                .font(.title3.bold())

            VStack(alignment: .leading, spacing: 16) {
                Toggle(isOn: Binding(
                    get: { viewModel.privacyLockEnabled },
                    set: { newValue in
                        Task {
                            await viewModel.handlePrivacyToggle(newValue)
                        }
                    }
                )) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Require Face ID / Passcode")
                            .font(.headline)
                        Text("Help protect your journal when you leave the app or lock your phone.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(Color(red: 0.43, green: 0.31, blue: 0.79))

                if !viewModel.privacyLockFeedback.isEmpty {
                    Text(viewModel.privacyLockFeedback)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(22)
            .background(Color.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }

    private var privacyInfoSection: some View {
        NavigationLink {
            PrivacySecurityView()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "lock.shield.fill")
                    .font(.title3)
                    .foregroundStyle(Color(red: 0.17, green: 0.28, blue: 0.59))
                    .frame(width: 48, height: 48)
                    .background(Color(red: 0.93, green: 0.96, blue: 0.99), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Privacy & Security")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("See how your journal is stored, protected, and kept private on this device.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(18)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityHint("Opens details about privacy and security in the app.")
    }

}

#Preview {
    NavigationStack {
        MoodJournalSettingsView(
            store: MoodJournalStore(),
            isLocked: false,
            privacyFeedback: "",
            unlockAction: {}
        )
    }
}
