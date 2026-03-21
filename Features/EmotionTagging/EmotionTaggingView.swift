//
//  EmotionTaggingView.swift
//  AppleIntelligenceForMyTutorial
//
//  Created by Codex on 15/03/2026.
//

import SwiftUI
import FoundationModels

// Option 3 kept for reference:
//
// @Generable
// struct EmotionTags {
//     @Generable
//     enum EmotionLabel: String {
//         case anxious
//         case stressed
//         case overwhelmed
//         case worried
//         case afraid
//         case sad
//         case angry
//         case frustrated
//         case calm
//         case hopeful
//         case excited
//         case happy
//
//         var emoji: String {
//             switch self {
//             case .anxious: "😰"
//             case .stressed: "😫"
//             case .overwhelmed: "😵"
//             case .worried: "😟"
//             case .afraid: "😨"
//             case .sad: "😢"
//             case .angry: "😠"
//             case .frustrated: "😤"
//             case .calm: "😌"
//             case .hopeful: "🙂"
//             case .excited: "🤩"
//             case .happy: "😀"
//             }
//         }
//     }
//
//     @Guide(description: "Choose 4 distinct emotions from the allowed set that best match the text.", .count(4))
//     let emotions: [EmotionLabel]
// }

@Generable
struct EmotionTags {
    @Guide(description: "The 4 most important emotions in the text.", .count(4))
    let emotions: [String]
}

struct EmotionTaggingView: View {
    @State private var inputText = "I'm really stressed about tomorrow's exam"
    @State private var result = "Tap the button to run the model."
    @State private var isLoading = false

    private let model = SystemLanguageModel(useCase: .contentTagging)
    private let emojiRules: [(emoji: String, keywords: [String])] = [
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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Foundation Models Test")
                .font(.title2.bold())

            Text("Enter text")
                .font(.headline)

            TextEditor(text: $inputText)
                .frame(minHeight: 80)
                .padding(12)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))

            Button {
                Task {
                    await generateEmotionTags()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Run Instruction")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Text(result)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding()
    }

    @MainActor
    private func generateEmotionTags() async {
        guard !isLoading else { return }

        guard model.isAvailable else {
            result = "Foundation model is not available: \(String(describing: model.availability))"
            return
        }

        let trimmedInput = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedInput.isEmpty else {
            result = "Enter some text first."
            return
        }

        isLoading = true
        defer { isLoading = false }

        let session = LanguageModelSession(model: model)
        let prompt = "List the 4 most important emotions in this text. Keep each emotion short and do not repeat emotions: \(trimmedInput)"

        do {
            let response: EmotionTags = try await session.respond(
                to: prompt,
                generating: EmotionTags.self
            ).content
            result = response.emotions
                .map { "\(emoji(for: $0)) \($0.capitalized)" }
                .joined(separator: "\n")
        } catch let error as LanguageModelSession.GenerationError {
            result = message(for: error)
        } catch let error as LanguageModelSession.ToolCallError {
            result = "Tool call error: \(error.errorDescription ?? error.localizedDescription)"
        } catch {
            result = "Unexpected error: \(error.localizedDescription)"
        }
    }

    private func message(for error: LanguageModelSession.GenerationError) -> String {
        switch error {
        case .assetsUnavailable(let context):
            return "Assets unavailable: \(context.debugDescription)"
        case .decodingFailure(let context):
            return "Decoding failure: \(context.debugDescription)"
        case .exceededContextWindowSize(let context):
            return "Context window exceeded: \(context.debugDescription)"
        case .guardrailViolation(let context):
            return "Guardrail violation: \(context.debugDescription)"
        case .rateLimited(let context):
            return "Rate limited: \(context.debugDescription)"
        case .refusal(_, let context):
            return "Model refusal: \(context.debugDescription)"
        case .concurrentRequests(let context):
            return "Concurrent request error: \(context.debugDescription)"
        case .unsupportedGuide(let context):
            return "Unsupported guide: \(context.debugDescription)"
        case .unsupportedLanguageOrLocale(let context):
            return "Unsupported language or locale: \(context.debugDescription)"
        @unknown default:
            return "Unhandled generation error: \(error.failureReason ?? error.localizedDescription)"
        }
    }

    private func emoji(for emotion: String) -> String {
        let value = emotion.lowercased()

        for rule in emojiRules {
            if rule.keywords.contains(where: value.contains) {
                return rule.emoji
            }
        }

        return "🙂"
    }
}
