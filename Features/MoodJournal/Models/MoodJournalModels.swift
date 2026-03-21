//
//  MoodJournalModels.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation
import FoundationModels
import SwiftData

@Generable
struct EmotionTagResponse {
    @Guide(description: "The 4 most important emotions in the text.", .count(4))
    let emotions: [String]
}

@Generable
struct ReflectionSummaryResponse {
    @Guide(description: "A warm, concise reflection summary in 2 short sentences.")
    let summary: String
}

struct SupportSuggestion: Codable, Hashable {
    let title: String
    let detail: String
    let symbol: String
}

struct JournalEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let createdAt: Date
    let suggestedEmotions: [String]
    let selectedEmotions: [String]
    let reflectionSummary: String
    let supportSuggestion: SupportSuggestion?
}

struct MoodFrequency: Identifiable, Hashable {
    let emotion: String
    let count: Int

    var id: String { emotion }
}

struct WeeklyMoodOverview: Hashable {
    let entriesCount: Int
    let currentStreak: Int
    let longestStreak: Int
    let topEmotions: [MoodFrequency]
}

struct MoodJournalAnalysisResult: Hashable {
    let suggestedEmotions: [String]
    let reflectionSummary: String
    let supportSuggestion: SupportSuggestion
}

struct MoodTrendDatum: Identifiable, Hashable {
    let emotion: String
    let count: Int

    var id: String { emotion }
}

@Generable
struct WeeklyRecapResponse {
    @Guide(description: "A concise, supportive weekly recap in 2 short sentences.")
    let summary: String
}

@Generable
struct WeeklyInsightResponse {
    @Guide(description: "A health-style pattern insight in 2 short sentences. Focus on emotional patterns, routines, and gentle self-awareness without diagnosis.")
    let insight: String
}

@Generable
struct SelfCareTipResponse {
    @Guide(description: "A short, uplifting title for a self-care tip. Keep it under 4 words.")
    let title: String

    @Guide(description: "A friendly self-care tip in 1 or 2 short sentences, ideally under 36 words total. Keep it non-medical, supportive, and concise.")
    let tip: String
}

struct SelfCareTip: Hashable {
    let title: String
    let tip: String
}

enum MoodJournalSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [JournalEntryRecord.self]
    }

    @Model
    final class JournalEntryRecord {
        @Attribute(.unique) var id: UUID
        var text: String
        var createdAt: Date
        var suggestedEmotionsData: Data
        var selectedEmotionsData: Data
        var reflectionSummary: String
        var supportSuggestionData: Data?

        init(
            id: UUID,
            text: String,
            createdAt: Date,
            suggestedEmotionsData: Data,
            selectedEmotionsData: Data,
            reflectionSummary: String,
            supportSuggestionData: Data?
        ) {
            self.id = id
            self.text = text
            self.createdAt = createdAt
            self.suggestedEmotionsData = suggestedEmotionsData
            self.selectedEmotionsData = selectedEmotionsData
            self.reflectionSummary = reflectionSummary
            self.supportSuggestionData = supportSuggestionData
        }
    }
}

typealias JournalEntryRecord = MoodJournalSchemaV1.JournalEntryRecord

enum MoodJournalMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [MoodJournalSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}

extension JournalEntryRecord {
    @MainActor
    convenience init(entry: JournalEntry) throws {
        self.init(
            id: entry.id,
            text: entry.text,
            createdAt: entry.createdAt,
            suggestedEmotionsData: try JSONEncoder().encode(entry.suggestedEmotions),
            selectedEmotionsData: try JSONEncoder().encode(entry.selectedEmotions),
            reflectionSummary: entry.reflectionSummary,
            supportSuggestionData: try entry.supportSuggestion.map { try JSONEncoder().encode($0) }
        )
    }

    @MainActor
    func makeEntry() throws -> JournalEntry {
        JournalEntry(
            id: id,
            text: text,
            createdAt: createdAt,
            suggestedEmotions: try JSONDecoder().decode([String].self, from: suggestedEmotionsData),
            selectedEmotions: try JSONDecoder().decode([String].self, from: selectedEmotionsData),
            reflectionSummary: reflectionSummary,
            supportSuggestion: try supportSuggestionData.map { try JSONDecoder().decode(SupportSuggestion.self, from: $0) }
        )
    }
}
