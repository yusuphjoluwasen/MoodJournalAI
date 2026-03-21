//
//  MoodJournalOnboardingView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct MoodJournalOnboardingView: View {
    let finish: (_ enablePrivacyLock: Bool) async -> String?

    @State private var currentStep = 0
    @State private var enablePrivacyLock = true
    @State private var isFinishing = false
    @State private var feedbackMessage = ""
    @State private var animateOrb = false

    private let steps: [OnboardingStep] = [
        OnboardingStep(
            symbol: "heart.text.square.fill",
            title: "Private reflection, every day",
            headline: "Capture moods, thoughts, and voice notes in one calm place.",
            detail: "Notice emotional patterns without turning reflection into homework.",
            colors: [Color(red: 0.15, green: 0.28, blue: 0.59), Color(red: 0.87, green: 0.43, blue: 0.28)]
        ),
        OnboardingStep(
            symbol: "sparkles.rectangle.stack.fill",
            title: "AI that stays supportive",
            headline: "Get mood suggestions, weekly reflections, and self-care prompts.",
            detail: "AI helps you reflect, while you stay in control of what gets saved.",
            colors: [Color(red: 0.14, green: 0.36, blue: 0.68), Color(red: 0.52, green: 0.29, blue: 0.73)]
        ),
        OnboardingStep(
            symbol: "lock.shield.fill",
            title: "Protect your journal",
            headline: "Use Face ID, Touch ID, or your passcode when opening the app again.",
            detail: "Choose this once now. You can change it later in Settings.",
            colors: [Color(red: 0.10, green: 0.24, blue: 0.48), Color(red: 0.79, green: 0.35, blue: 0.23)]
        )
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.07, green: 0.09, blue: 0.18), Color(red: 0.16, green: 0.29, blue: 0.54), Color(red: 0.91, green: 0.45, blue: 0.31)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: animateOrb ? 320 : 250, height: animateOrb ? 320 : 250)
                .blur(radius: 28)
                .offset(x: 110, y: -260)

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: animateOrb ? 220 : 170, height: animateOrb ? 220 : 170)
                .blur(radius: 18)
                .offset(x: -120, y: 280)

            VStack(spacing: 24) {
                Spacer(minLength: 12)

                TabView(selection: $currentStep) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        onboardingCard(step: step, isPrivacyStep: index == steps.count - 1)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: 470)

                HStack(spacing: 8) {
                    ForEach(steps.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ? Color.white : Color.white.opacity(0.28))
                            .frame(width: index == currentStep ? 30 : 10, height: 10)
                            .animation(.spring(duration: 0.35, bounce: 0.25), value: currentStep)
                    }
                }

                if !feedbackMessage.isEmpty {
                    Text(feedbackMessage)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                }

                actionRow
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 28)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                animateOrb = true
            }
        }
    }

    private func onboardingCard(step: OnboardingStep, isPrivacyStep: Bool) -> some View {
        VStack(alignment: .leading, spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.white.opacity(0.12))
                        .frame(width: 92, height: 92)
                        .overlay(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .stroke(.white.opacity(0.16), lineWidth: 1)
                        )

                    Image(systemName: step.symbol)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(step.title)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(.white)

                    Text(step.headline)
                        .font(.headline.weight(.semibold))
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                        .foregroundStyle(.white.opacity(0.94))

                    Text(step.detail)
                        .font(.footnote)
                        .lineLimit(3)
                        .minimumScaleFactor(0.84)
                        .foregroundStyle(.white.opacity(0.78))
                }

                if isPrivacyStep {
                    privacyChoiceCard
                } else {
                    featureHighlights(colors: step.colors)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            LinearGradient(
                colors: step.colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 34, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 26, y: 16)
    }

    private func featureHighlights(colors: [Color]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow(symbol: "waveform", title: "Voice entry", detail: "Speak and turn it into journal text.")
            featureRow(symbol: "chart.bar.fill", title: "Weekly patterns", detail: "Spot mood trends across the week.")
        }
        .padding(14)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var privacyChoiceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $enablePrivacyLock) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Enable Face ID / Passcode lock")
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(2)
                        .minimumScaleFactor(0.84)
                        .foregroundStyle(.white)
                    Text("Lock the journal when you come back to the app.")
                        .font(.footnote)
                        .lineLimit(2)
                        .minimumScaleFactor(0.84)
                        .foregroundStyle(.white.opacity(0.78))
                }
            }
            .toggleStyle(.switch)
            .tint(Color.white.opacity(0.9))

            privacyPill(symbol: "eye.slash.fill", text: "Private by default")
        }
        .padding(14)
        .background(Color.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func privacyPill(symbol: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: symbol)
            Text(text)
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(.white)
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.10), in: Capsule())
    }

    private func featureRow(symbol: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Text(detail)
                    .font(.footnote)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
                    .foregroundStyle(.white.opacity(0.76))
            }
        }
    }

    private var actionRow: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button("Back") {
                    feedbackMessage = ""
                    withAnimation(.spring(duration: 0.35, bounce: 0.22)) {
                        currentStep -= 1
                    }
                }
                .fontWeight(.semibold)
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .foregroundStyle(.white)
            }

            Button {
                Task {
                    await handlePrimaryAction()
                }
            } label: {
                HStack(spacing: 8) {
                    if isFinishing {
                        ProgressView()
                            .tint(Color(red: 0.17, green: 0.28, blue: 0.59))
                    }
                    Text(primaryButtonTitle)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                .foregroundStyle(Color(red: 0.17, green: 0.28, blue: 0.59))
            }
            .buttonStyle(.plain)
            .disabled(isFinishing)
        }
    }

    private var primaryButtonTitle: String {
        currentStep == steps.count - 1 ? "Continue" : "Next"
    }

    @MainActor
    private func handlePrimaryAction() async {
        feedbackMessage = ""

        if currentStep < steps.count - 1 {
            withAnimation(.spring(duration: 0.4, bounce: 0.22)) {
                currentStep += 1
            }
            return
        }

        isFinishing = true
        let failureMessage = await finish(enablePrivacyLock)
        isFinishing = false

        if let failureMessage {
            feedbackMessage = failureMessage
        }
    }
}

private struct OnboardingStep {
    let symbol: String
    let title: String
    let headline: String
    let detail: String
    let colors: [Color]
}

#Preview {
    MoodJournalOnboardingView { _ in nil }
}
