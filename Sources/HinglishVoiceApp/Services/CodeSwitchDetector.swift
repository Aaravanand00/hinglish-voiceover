import Foundation
import NaturalLanguage

/// Service responsible for identifying language boundaries (Hindi vs English) at the word & token level.
public final class CodeSwitchDetector: Sendable {
    public static let shared = CodeSwitchDetector()
    
    // Common Romanized Hindi words encountered in Hinglish voice commands
    private let romanizedHindiVocabulary: Set<String> = [
        "kal", "kl", "aaj", "aj", "parso", "parson", "subah", "shaam", "dopahar", "raat",
        "baje", "bj", "ghante", "ghanta", "minute", "minat",
        "yaad", "dila", "dilana", "dilaao", "laga", "lagao", "lagana", "karo", "karna",
        "ko", "ka", "ki", "ke", "se", "pe", "par", "me", "mein", "liye",
        "jao", "chalo", "wapas", "kholo", "band", "batao", "bhejo", "bhejna", "likho",
        "padho", "dikhao", "sunao", "kya", "hai", "hain", "karna", "hoga", "hogi",
        "phone", "fon", "baat", "karni", "mujhe", "mera", "meri", "mere", "hum", "aap", "tum"
    ]
    
    // Common English words frequently used in everyday Hinglish
    private let commonEnglishVocabulary: Set<String> = [
        "reminder", "remind", "alarm", "call", "message", "text", "dial",
        "home", "back", "settings", "help", "screen", "describe", "read",
        "meeting", "gym", "doctor", "medicine", "office", "flight", "train", "bus",
        "am", "pm", "clock", "set", "create", "open", "close", "start", "stop"
    ]
    
    public init() {}
    
    /// Analyzes a Hinglish sentence and returns word-by-word language classification tokens.
    public func analyze(text: String) -> [CodeSwitchToken] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = trimmed
        
        var tokens: [CodeSwitchToken] = []
        var wordIndex = 0
        
        tokenizer.enumerateTokens(in: trimmed.startIndex..<trimmed.endIndex) { tokenRange, _ in
            let rawWord = String(trimmed[tokenRange])
            let lowerWord = rawWord.lowercased()
            
            let (tag, confidence) = detectWordLanguage(word: lowerWord, original: rawWord)
            
            tokens.append(
                CodeSwitchToken(
                    word: rawWord,
                    index: wordIndex,
                    languageTag: tag,
                    confidence: confidence
                )
            )
            wordIndex += 1
            return true
        }
        
        return tokens
    }
    
    /// Classifies an individual word into Hindi, English, or Undetermined.
    private func detectWordLanguage(word: String, original: String) -> (DetectedLanguageTag, Double) {
        // 1. Check Devanagari unicode block (Unicode range 0900-097F) -> 100% Hindi
        if original.unicodeScalars.contains(where: { $0.value >= 0x0900 && $0.value <= 0x097F }) {
            return (.hindi, 0.99)
        }
        
        // 2. Exact match in Romanized Hindi vocabulary
        if romanizedHindiVocabulary.contains(word) {
            return (.hindi, 0.95)
        }
        
        // 3. Exact match in English vocabulary
        if commonEnglishVocabulary.contains(word) {
            return (.english, 0.95)
        }
        
        // 4. Fallback to NaturalLanguage framework NLLanguageRecognizer
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(word)
        
        if let dominant = recognizer.dominantLanguage {
            switch dominant {
            case .hindi:
                return (.hindi, 0.85)
            case .english:
                return (.english, 0.85)
            default:
                // Check hypotheses
                let hypotheses = recognizer.languageHypotheses(withMaximum: 2)
                if let enConf = hypotheses[.english], enConf > 0.4 {
                    return (.english, enConf)
                } else if let hiConf = hypotheses[.hindi], hiConf > 0.4 {
                    return (.hindi, hiConf)
                }
                return (.mixedOrNeutral, 0.50)
            }
        }
        
        // 5. Default heuristic: If word is alphabetic only, default to English/Neutral
        return (.mixedOrNeutral, 0.50)
    }
    
    /// Computes summary statistics of code-mixing ratio in an utterance.
    public func codeSwitchRatio(tokens: [CodeSwitchToken]) -> (hindiRatio: Double, englishRatio: Double) {
        guard !tokens.isEmpty else { return (0, 0) }
        let hiCount = tokens.filter { $0.languageTag == .hindi }.count
        let enCount = tokens.filter { $0.languageTag == .english }.count
        let total = Double(tokens.count)
        return (Double(hiCount) / total, Double(enCount) / total)
    }
}
