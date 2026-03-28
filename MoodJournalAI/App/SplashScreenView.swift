//
//  SplashScreenView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isExpanded = false
    @State private var showGlow = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.09, blue: 0.18),
                    Color(red: 0.16, green: 0.29, blue: 0.54),
                    Color(red: 0.91, green: 0.45, blue: 0.31)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(showGlow ? 0.18 : 0.08))
                .frame(width: showGlow ? 280 : 210, height: showGlow ? 280 : 210)
                .blur(radius: 20)
                .accessibilityHidden(true)

            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(.white.opacity(0.12))
                        .frame(width: 116, height: 116)
                        .overlay(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .stroke(.white.opacity(0.16), lineWidth: 1)
                        )

                    Image(systemName: "heart.text.square.fill")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.white)
                        .accessibilityHidden(true)
                }
                .scaleEffect(isExpanded ? 1.0 : 0.82)
                .accessibilityHidden(true)

                VStack(spacing: 8) {
                    Text("Mood Journal")
                        .font(.largeTitle.weight(.bold))
                        .fontDesign(.rounded)
                        .foregroundStyle(.white)

                    Text("Reflect privately. Understand patterns. Stay grounded.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.84))
                        .padding(.horizontal, 28)
                }
            }
            .padding(24)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Mood Journal. Reflect privately. Understand patterns. Stay grounded.")
        }
        .onAppear {
            withAnimation(.spring(duration: 0.9, bounce: 0.3)) {
                isExpanded = true
            }

            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                showGlow = true
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
