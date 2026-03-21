//
//  ContentView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Guru King on 15/03/2026.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplash = true
    @State private var store = MoodJournalStore()
    @State private var isLocked = false
    @State private var privacyLockFeedback = ""

    private let privacyAuthenticator = MoodJournalPrivacyAuthenticator()

    var body: some View {
        ZStack {
            TabView {
                NavigationStack {
                    MoodJournalView(store: store, isLocked: isLocked, unlockAction: unlockJournal)
                }
                .tabItem {
                    Label("Home", systemImage: "heart.text.square")
                }

                NavigationStack {
                    MoodJournalHistoryView(store: store)
                }
                .tabItem {
                    Label("History", systemImage: "calendar")
                }

                NavigationStack {
                    SelfCareTipsView()
                }
                .tabItem {
                    Label("Self Care", systemImage: "sparkles")
                }

                NavigationStack {
                    MoodJournalSettingsView(
                        store: store,
                        isLocked: isLocked,
                        privacyFeedback: privacyLockFeedback,
                        unlockAction: unlockJournal
                    )
                }
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
            }

            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            } else if isLocked {
                ZStack {
                    Color.black.opacity(0.22)
                        .ignoresSafeArea()

                    PrivacyLockCard(
                        isLocked: true,
                        feedback: privacyLockFeedback,
                        unlockAction: unlockJournal
                    )
                    .padding(20)
                }
                    .zIndex(1)
            }
        }
        .task {
            guard showSplash else { return }

            try? await Task.sleep(for: .milliseconds(1800))

            withAnimation(.easeOut(duration: 0.35)) {
                showSplash = false
            }
        }
        .task {
            store.configure(modelContext: modelContext)
        }
        .task {
            if store.privacyLockEnabled {
                isLocked = true
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background && store.privacyLockEnabled {
                isLocked = true
            }
        }
    }

    @MainActor
    private func unlockJournal() {
        Task {
            do {
                try await privacyAuthenticator.authenticate(reason: "Unlock your Mood Journal.")
                isLocked = false
                privacyLockFeedback = ""
            } catch {
                privacyLockFeedback = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
