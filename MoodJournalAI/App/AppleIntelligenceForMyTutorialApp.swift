//
//  AppleIntelligenceForMyTutorialApp.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Guru King on 15/03/2026.
//

import SwiftUI
import SwiftData

@main
struct AppleIntelligenceForMyTutorialApp: App {
    private let sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: MoodJournalSchemaV1.self)

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: MoodJournalMigrationPlan.self
            )
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(sharedModelContainer)
    }
}
