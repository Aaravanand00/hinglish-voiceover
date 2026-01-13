import Foundation

/// High-level categories of supported Hinglish Voice commands.
public enum IntentCategory: String, Codable, CaseIterable, Sendable {
    case reminder = "Reminder & Alarm"
    case contactAction = "Calls & Messages"
    case navigation = "App Navigation"
    case unknown = "Unknown Intent"
    
    public var accessibilityDescription: String {
        switch self {
        case .reminder:
            return "Reminder ya Alarm category"
        case .contactAction:
            return "Call ya Message category"
        case .navigation:
            return "Navigation category"
        case .unknown:
            return "Samajh nahi aaya"
        }
    }
}

/// Specific concrete actions within each category.
public enum SpecificAction: String, Codable, Sendable {
    // Category 1: Reminders & Alarms
    case createReminder = "create_reminder"
    case setAlarm = "set_alarm"
    
    // Category 2: Contacts
    case makePhoneCall = "make_call"
    case sendTextMessage = "send_message"
    
    // Category 3: Navigation
    case navigateHome = "navigate_home"
    case navigateBack = "navigate_back"
    case openSettings = "open_settings"
    case openHelp = "open_help"
    case readScreen = "read_screen"
    
    // Unknown fallback
    case fallbackUnknown = "unknown"
}

/// The parsed structured command result from the Hinglish Intent Engine.
public struct ParsedCommand: Codable, Equatable, Sendable {
    public let rawTranscript: String
    public let normalizedTranscript: String
    public let category: IntentCategory
    public let action: SpecificAction
    public let entities: ExtractedEntities
    public let confidence: Double
    public let responseVoiceMessage: String
    public let isExecutable: Bool
    
    public init(
        rawTranscript: String,
        normalizedTranscript: String,
        category: IntentCategory,
        action: SpecificAction,
        entities: ExtractedEntities = ExtractedEntities(),
        confidence: Double = 1.0,
        responseVoiceMessage: String,
        isExecutable: Bool = true
    ) {
        self.rawTranscript = rawTranscript
        self.normalizedTranscript = normalizedTranscript
        self.category = category
        self.action = action
        self.entities = entities
        self.confidence = confidence
        self.responseVoiceMessage = responseVoiceMessage
        self.isExecutable = isExecutable
    }
    
    public static func unknown(raw: String) -> ParsedCommand {
        ParsedCommand(
            rawTranscript: raw,
            normalizedTranscript: raw.lowercased(),
            category: .unknown,
            action: .fallbackUnknown,
            entities: ExtractedEntities(),
            confidence: 0.0,
            responseVoiceMessage: "Maaf kijiye, ye command samajh nahi aayi. Kripya dobara bolein.",
            isExecutable: false
        )
    }
}
