//
//  PrivacySecurityView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct PrivacySecurityView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Privacy & Security")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Your journal stays on your device.")
                    Text("Mood Journal is designed to keep your writing, summaries, and settings private by default.")
                }
                .font(.headline)
                .foregroundStyle(.white.opacity(0.72))

                PrivacyInfoCard(
                    icon: "iphone",
                    title: "Saved on your phone",
                    message: "Your journal entries, reminders, and privacy choices stay on this phone unless you decide to share or export them."
                )

                PrivacyInfoCard(
                    icon: "apple.logo",
                    title: "Private smart features",
                    message: "When these features are available on your device, the app can suggest moods, write reflections, and create gentle self-care ideas without sending your journal somewhere else."
                )

                PrivacyInfoCard(
                    icon: "hand.raised.fill",
                    title: "You're in control",
                    message: "Nothing is shared unless you explicitly export it. You choose what moods to save, whether reminders are enabled, and whether Face ID or passcode lock is required."
                )

                PrivacyInfoCard(
                    icon: "bell.badge.fill",
                    title: "Private reminders",
                    message: "Daily reminders are created by your phone for your phone. They do not depend on an outside service."
                )

                PrivacyInfoCard(
                    icon: "eye.slash.fill",
                    title: "No hidden tracking",
                    message: "This app is not watching your behavior for ads or selling your information to outside companies."
                )

                PrivacyInfoCard(
                    icon: "lock.shield.fill",
                    title: "Extra protection",
                    message: "If you enable Privacy Lock, the journal can require Face ID, Touch ID, or your device passcode when you come back to the app."
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Important")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("This app supports reflection and self-awareness. It is not a medical device and does not diagnose health conditions.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.74))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.41, green: 0.16, blue: 0.18), Color(red: 0.26, green: 0.10, blue: 0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
            }
            .padding(20)
        }
        .background(Color.black.ignoresSafeArea())
        .navigationTitle("Privacy & Security")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct PrivacyInfoCard: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.72))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        PrivacySecurityView()
    }
}
