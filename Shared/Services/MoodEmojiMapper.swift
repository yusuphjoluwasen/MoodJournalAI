//
//  MoodEmojiMapper.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import Foundation

enum MoodEmojiMapper {
    private static let rules: [(emoji: String, keywords: [String])] = [
        ("😰", ["anx", "stress", "nerv", "tense", "uneasy"]),
        ("😵", ["overwhelm", "exhaust", "drain", "burnout"]),
        ("😟", ["worr", "concern", "uncertain", "doubt"]),
        ("😨", ["afraid", "fear", "scared", "terrified", "panic"]),
        ("😢", ["sad", "down", "upset", "gloom", "depress", "heartbroken"]),
        ("😡", ["ang", "mad", "furious", "rage", "irritat"]),
        ("😤", ["frustrat", "annoy", "bother", "agitated"]),
        ("😌", ["calm", "peace", "relaxed", "settled", "serene"]),
        ("🙂", ["hope", "optim", "encouraged", "positive"]),
        ("🤩", ["excite", "thrill", "eager", "enthusias"]),
        ("😀", ["happy", "joy", "glad", "delight", "cheerful"]),
        ("🥰", ["affection", "adoration", "fond", "warmth"]),
        ("❤️", ["love", "adore", "romance", "romantic"]),
        ("😲", ["surpris", "shock", "astonish"]),
        ("🤔", ["confus", "puzzled", "unsure"]),
        ("😳", ["embarrass", "awkward", "self-conscious"]),
        ("😔", ["guilt", "ashamed", "regret"]),
        ("🥺", ["lonely", "isolat"]),
        ("🙏", ["grateful", "thankful", "appreciat"]),
        ("😎", ["proud", "confident", "accomplish"]),
        ("🧐", ["curious", "interested", "intrigued"]),
        ("😐", ["bored", "indifferent", "uninterested"]),
        ("🫣", ["shy", "timid", "hesitant"])
    ]

    static func emoji(for emotion: String) -> String {
        let value = emotion.lowercased()

        for rule in rules where rule.keywords.contains(where: value.contains) {
            return rule.emoji
        }

        return "🙂"
    }
}
