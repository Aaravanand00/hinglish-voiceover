import Foundation

/// Extracted slot parameters from a code-mixed command (Time, Date, Contact, Query, etc.)
public struct ExtractedEntities: Codable, Equatable, Sendable {
    public var contactName: String?
    public var reminderTitle: String?
    public var dateString: String?
    public var timeString: String?
    public var targetHour: Int?
    public var targetMinute: Int?
    public var targetDate: Date?
    public var messageContent: String?
    public var navigationTarget: String?
    
    public init(
        contactName: String? = nil,
        reminderTitle: String? = nil,
        dateString: String? = nil,
        timeString: String? = nil,
        targetHour: Int? = nil,
        targetMinute: Int? = nil,
        targetDate: Date? = nil,
        messageContent: String? = nil,
        navigationTarget: String? = nil
    ) {
        self.contactName = contactName
        self.reminderTitle = reminderTitle
        self.dateString = dateString
        self.timeString = timeString
        self.targetHour = targetHour
        self.targetMinute = targetMinute
        self.targetDate = targetDate
        self.messageContent = messageContent
        self.navigationTarget = navigationTarget
    }
}
