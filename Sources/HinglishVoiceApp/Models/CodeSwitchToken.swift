import Foundation

/// Supported language tags in code-mixed Hinglish utterances.
public enum DetectedLanguageTag: String, Codable, Sendable {
    case hindi = "hi"
    case english = "en"
    case mixedOrNeutral = "und"
    
    public var displayName: String {
        switch self {
        case .hindi: return "Hindi"
        case .english: return "English"
        case .mixedOrNeutral: return "Neutral / Mixed"
        }
    }
}

/// Tokenized word with detected language tag and confidence score.
public struct CodeSwitchToken: Identifiable, Codable, Equatable, Sendable {
    public var id: String { "\(word)_\(index)" }
    public let word: String
    public let index: Int
    public let languageTag: DetectedLanguageTag
    public let confidence: Double
    
    public init(word: String, index: Int, languageTag: DetectedLanguageTag, confidence: Double) {
        self.word = word
        self.index = index
        self.languageTag = languageTag
        self.confidence = confidence
    }
}
