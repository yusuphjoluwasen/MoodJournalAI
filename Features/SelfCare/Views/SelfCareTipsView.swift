//
//  SelfCareTipsView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI

struct SelfCareTipsView: View {
    @State private var tip: SelfCareTip?
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var refreshID = UUID()

    private let analyzer = MoodJournalAnalyzer()

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 10)

            VStack(alignment: .leading, spacing: 18) {
                if isLoading {
                    VStack(spacing: 18) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Generating a fresh tip...")
                        .font(.headline)
                    }
                    .frame(maxWidth: .infinity, minHeight: 320, alignment: .topLeading)
                } else if let tip {
                    Text(tip.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.85)
                    Text(tip.tip)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .lineSpacing(3)
                        .lineLimit(7)
                        .minimumScaleFactor(0.8)
                } else if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 320, alignment: .topLeading)
            .padding(26)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.97, green: 0.78, blue: 0.57), Color(red: 0.91, green: 0.93, blue: 0.73)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 32, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )

            Button {
                guard !isLoading else { return }
                refreshID = UUID()
            } label: {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                    }
                    Text(isLoading ? "Loading..." : "Next Tip")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isLoading ? Color(red: 0.47, green: 0.62, blue: 0.84) : Color(red: 0.18, green: 0.39, blue: 0.72),
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(isLoading)

            Spacer()
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(red: 1.00, green: 0.97, blue: 0.93), Color(red: 0.93, green: 0.97, blue: 0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Self Care")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: refreshID) {
            await generateTip()
        }
    }

    @MainActor
    private func generateTip() async {
        isLoading = true
        errorMessage = ""
        defer { isLoading = false }

        do {
            tip = try await analyzer.selfCareTip()
        } catch {
            tip = nil
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SelfCareTipsView()
    }
}
