import Foundation

/// Core parsing engine for extracting structured commands and slots from Hinglish utterances.
public final class HinglishIntentParser: Sendable {
    public static let shared = HinglishIntentParser()
    
    public init() {}
    
    /// Main entry point: Parses any Hinglish sentence into a structured `ParsedCommand`.
    public func parse(transcript: String) -> ParsedCommand {
        let trimmed = transcript.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return ParsedCommand.unknown(raw: transcript)
        }
        
        let normalized = normalize(transcript: trimmed)
        
        // 1. Check Category 1: Navigation & System Commands (Higher priority for exact short phrases)
        if let navCommand = tryParseNavigation(raw: trimmed, normalized: normalized) {
            return navCommand
        }
        
        // 2. Check Category 2: Contacts (Calls & Messages)
        if let contactCommand = tryParseContactAction(raw: trimmed, normalized: normalized) {
            return contactCommand
        }
        
        // 3. Check Category 3: Reminders & Alarms
        if let reminderCommand = tryParseReminderOrAlarm(raw: trimmed, normalized: normalized) {
            return reminderCommand
        }
        
        // 4. Fallback unknown
        return ParsedCommand.unknown(raw: trimmed)
    }
    
    // MARK: - Normalization
    
    public func normalize(transcript: String) -> String {
        var text = transcript.lowercased()
        
        // Remove common punctuation
        let punctuation = CharacterSet(charactersIn: ",.!?;:'\"-()")
        text = text.components(separatedBy: punctuation).joined(separator: " ")
        
        // Replace multiple spaces
        text = text.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        // Transliteration normalizations
        let mapping: [String: String] = [
            "kl": "kal",
            "aj": "aaj",
            "parson": "parso",
            "bj": "baje",
            "bje": "baje",
            "fon": "phone",
            "mgs": "message",
            "msg": "message",
            "remnd": "remind",
            "set kr do": "set karo",
            "lga do": "lagao",
            "bhej do": "bhejo"
        ]
        
        for (source, target) in mapping {
            text = text.replacingOccurrences(of: "\\b\(source)\\b", with: target, options: .regularExpression)
        }
        
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Category 1: Navigation Parser
    
    private func tryParseNavigation(raw: String, normalized: String) -> ParsedCommand? {
        // Home Navigation
        let homePatterns = [
            "home", "home screen", "home jao", "home chalo", "home pe jao",
            "home screen pe jao", "home screen pe wapas jao", "go home", "main screen", "mukhya prishth"
        ]
        if homePatterns.contains(where: { normalized.contains($0) }) {
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .navigation,
                action: .navigateHome,
                entities: ExtractedEntities(navigationTarget: "home"),
                confidence: 0.95,
                responseVoiceMessage: "Home screen par wapas ja rahe hain.",
                isExecutable: true
            )
        }
        
        // Back Navigation
        let backPatterns = [
            "wapas", "wapas jao", "wapas chalo", "pichle page", "peeche jao", "peeche chalo",
            "back jao", "go back", "pichhe jao", "pichhe chalo", "back chalo"
        ]
        if backPatterns.contains(where: { normalized.contains($0) }) {
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .navigation,
                action: .navigateBack,
                entities: ExtractedEntities(navigationTarget: "back"),
                confidence: 0.95,
                responseVoiceMessage: "Pichle page par wapas ja rahe hain.",
                isExecutable: true
            )
        }
        
        // Settings Navigation
        let settingsPatterns = [
            "setting", "settings", "settings kholo", "setting kholo", "open settings",
            "settings me jao", "setting pe jao"
        ]
        if settingsPatterns.contains(where: { normalized.contains($0) }) {
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .navigation,
                action: .openSettings,
                entities: ExtractedEntities(navigationTarget: "settings"),
                confidence: 0.95,
                responseVoiceMessage: "Settings open kar rahe hain.",
                isExecutable: true
            )
        }
        
        // Help / Phrase Guide
        let helpPatterns = [
            "help", "madad", "help kholo", "madad chahiye", "commands batao",
            "kya bol sakte hain", "kya kya bol sakte hain", "phrases guide", "guide kholo", "guide dikhao", "guide"
        ]
        if helpPatterns.contains(where: { normalized.contains($0) }) {
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .navigation,
                action: .openHelp,
                entities: ExtractedEntities(navigationTarget: "help"),
                confidence: 0.95,
                responseVoiceMessage: "Supported commands ki guide open kar rahe hain.",
                isExecutable: true
            )
        }
        
        // Screen Reader / Describe Screen
        let screenReadPatterns = [
            "ye kya hai", "screen padho", "screen pe kya hai", "describe screen",
            "kya likha hai", "padh ke batao", "screen describe karo"
        ]
        if screenReadPatterns.contains(where: { normalized.contains($0) }) {
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .navigation,
                action: .readScreen,
                entities: ExtractedEntities(navigationTarget: "current_screen"),
                confidence: 0.95,
                responseVoiceMessage: "Screen par upalabdh jankari padhi ja rahi hai.",
                isExecutable: true
            )
        }
        
        return nil
    }
    
    // MARK: - Category 2: Contact Actions (Call & Message)
    
    private func tryParseContactAction(raw: String, normalized: String) -> ParsedCommand? {
        let isCall = normalized.contains("call") || normalized.contains("phone") || normalized.contains("dial") || normalized.contains("baat")
        let isMessage = normalized.contains("message") || normalized.contains("text") || normalized.contains("sms") || normalized.contains("bhejo")
        
        guard isCall || isMessage else { return nil }
        
        // Extract Contact Name
        var contactName: String? = nil
        var messageBody: String? = nil
        
        // Regex 1: (.*) ko (call|phone|message|text)
        if let match = normalized.range(of: "^(.*?) ko (call|phone|dial|message|text|bhejo)", options: .regularExpression) {
            let matchedSubstring = String(normalized[match])
            if let koRange = matchedSubstring.range(of: " ko ") {
                let namePart = String(matchedSubstring[..<koRange.lowerBound]).trimmingCharacters(in: .whitespaces)
                let cleanedName = cleanContactName(namePart)
                if !cleanedName.isEmpty {
                    contactName = cleanedName
                }
            }
        }
        
        // Regex 2: (call|phone|dial|message|text) (to )?(.*)
        if contactName == nil {
            let actionWords = ["call", "phone lagao", "dial", "message bhejo", "text karo"]
            for actionWord in actionWords {
                if let range = normalized.range(of: actionWord) {
                    let afterAction = String(normalized[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    let words = afterAction.components(separatedBy: " ")
                    if let firstWord = words.first, !firstWord.isEmpty, !["ko", "to", "karo", "lagao"].contains(firstWord) {
                        contactName = cleanContactName(firstWord)
                        break
                    }
                }
            }
        }
        
        // Extract Message Body if applicable
        if isMessage {
            if let kiRange = normalized.range(of: " ki ") {
                messageBody = String(normalized[kiRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            } else if let thatRange = normalized.range(of: " that ") {
                messageBody = String(normalized[thatRange.upperBound...]).trimmingCharacters(in: .whitespaces)
            }
        }
        
        let targetName = contactName ?? "Contact"
        
        if isMessage {
            let entities = ExtractedEntities(contactName: targetName, messageContent: messageBody)
            let response = messageBody != nil
                ? "\(targetName) ko message bheja ja raha hai: '\(messageBody!)'"
                : "\(targetName) ke liye message compose kiya ja raha hai."
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .contactAction,
                action: .sendTextMessage,
                entities: entities,
                confidence: contactName != nil ? 0.95 : 0.80,
                responseVoiceMessage: response,
                isExecutable: true
            )
        } else {
            let entities = ExtractedEntities(contactName: targetName)
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .contactAction,
                action: .makePhoneCall,
                entities: entities,
                confidence: contactName != nil ? 0.95 : 0.80,
                responseVoiceMessage: "\(targetName) ko phone call lagayi ja rahi hai.",
                isExecutable: true
            )
        }
    }
    
    // MARK: - Category 3: Reminders & Alarms
    
    private func tryParseReminderOrAlarm(raw: String, normalized: String) -> ParsedCommand? {
        let isReminderExplicit = normalized.contains("remind") || normalized.contains("reminder") || normalized.contains("yaad") || normalized.contains("dila")
        let isAlarmKeyword = normalized.contains("alarm") || normalized.contains("jaga dena") || normalized.contains("wake me")
        
        // Implicit reminder heuristic: relative date (kal/aaj/parso) OR time (baje/am/pm) combined with task words (appointment, flight, gym, doctor, meeting, etc.)
        let taskWords = ["appointment", "flight", "doctor", "meeting", "gym", "dawai", "medicine", "yoga", "grocery", "car service"]
        let hasDateOrTime = normalized.contains("kal") || normalized.contains("aaj") || normalized.contains("parso") || normalized.contains("baje") || normalized.contains("am") || normalized.contains("pm")
        let isImplicitReminder = hasDateOrTime && taskWords.contains(where: { normalized.contains($0) })
        
        guard isReminderExplicit || isAlarmKeyword || isImplicitReminder else { return nil }
        
        // Extract Time & Date entities
        let timeEntities = extractTimeAndDate(from: normalized)
        
        if isAlarmKeyword {
            let displayTime = timeEntities.timeString ?? "6:00 AM"
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .reminder,
                action: .setAlarm,
                entities: timeEntities,
                confidence: 0.90,
                responseVoiceMessage: "\(displayTime) ke liye alarm set kar diya gaya hai.",
                isExecutable: true
            )
        } else {
            // Reminder
            let title = extractReminderTitle(from: normalized)
            var finalEntities = timeEntities
            finalEntities.reminderTitle = title
            
            let timeDesc = finalEntities.timeString != nil ? " \(finalEntities.timeString!) ke liye" : ""
            let dateDesc = finalEntities.dateString != nil ? " \(finalEntities.dateString!)" : ""
            let response = "'\(title)' ka reminder\(dateDesc)\(timeDesc) set kar diya gaya hai."
            
            return ParsedCommand(
                rawTranscript: raw,
                normalizedTranscript: normalized,
                category: .reminder,
                action: .createReminder,
                entities: finalEntities,
                confidence: 0.92,
                responseVoiceMessage: response,
                isExecutable: true
            )
        }
    }
    
    // MARK: - Helper Extraction Functions
    
    private func cleanContactName(_ raw: String) -> String {
        var name = raw
        let noisePrefixes = ["are", "bhai", "please", "kripya", "zara", "ek", "baar"]
        for prefix in noisePrefixes {
            if name.starts(with: "\(prefix) ") {
                name = String(name.dropFirst(prefix.count + 1))
            }
        }
        return name.capitalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func extractTimeAndDate(from text: String) -> ExtractedEntities {
        var entities = ExtractedEntities()
        
        // 1. Date resolution
        if text.contains("kal") || text.contains("tomorrow") {
            entities.dateString = "Kal (Tomorrow)"
        } else if text.contains("aaj") || text.contains("today") {
            entities.dateString = "Aaj (Today)"
        } else if text.contains("parso") || text.contains("day after tomorrow") {
            entities.dateString = "Parso"
        }
        
        // 2. Time extraction
        let isMorning = text.contains("subah") || text.contains("morning") || text.contains("am")
        let isEvening = text.contains("shaam") || text.contains("evening") || text.contains("raat") || text.contains("night") || text.contains("pm")
        let isAfternoon = text.contains("dopahar") || text.contains("afternoon")
        
        if let regex = try? NSRegularExpression(pattern: #"(\d{1,2})(:(\d{2}))?\s*(baje|am|pm)?"#, options: .caseInsensitive) {
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
            
            for match in matches {
                let hourStr = nsString.substring(with: match.range(at: 1))
                if var hour = Int(hourStr), hour >= 1 && hour <= 24 {
                    var minute = 0
                    if match.range(at: 3).location != NSNotFound {
                        let minStr = nsString.substring(with: match.range(at: 3))
                        minute = Int(minStr) ?? 0
                    }
                    
                    if isEvening && hour < 12 {
                        hour += 12
                    } else if isAfternoon && hour < 12 && hour != 12 {
                        hour += 12
                    }
                    
                    entities.targetHour = hour
                    entities.targetMinute = minute
                    entities.timeString = String(format: "%02d:%02d %@", (hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)), minute, (hour >= 12 ? "PM" : "AM"))
                    break
                }
            }
        }
        
        return entities
    }
    
    private func extractReminderTitle(from text: String) -> String {
        var subject = text
        
        let removalPatterns = [
            "kal subah", "kal shaam", "kal", "aaj", "parso",
            "yaad dila dena", "yaad dilao", "remind kar dena", "ka reminder laga do",
            "reminder set karo", "reminder laga do", "remind me", "set a reminder",
            "baje", "ki", "ko", "hai", "mujhe"
        ]
        
        for pattern in removalPatterns {
            subject = subject.replacingOccurrences(of: "\\b\(pattern)\\b", with: "", options: .regularExpression)
        }
        
        subject = subject.replacingOccurrences(of: "\\b\\d{1,2}(:\\d{2})?\\b", with: "", options: .regularExpression)
        subject = subject.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if subject.isEmpty {
            return "Reminder"
        }
        return subject.capitalized
    }
}
