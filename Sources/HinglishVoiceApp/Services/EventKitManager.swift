import Foundation
import EventKit

/// Manages interaction with Apple EventKit for creating Reminders & Alarms.
public final class EventKitManager: @unchecked Sendable {
    public static let shared = EventKitManager()
    
    private let eventStore = EKEventStore()
    
    public init() {}
    
    /// Requests user permission to access Reminders.
    public func requestReminderAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestFullAccessToReminders()
            } catch {
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .reminder) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    /// Creates a reminder in the user's default reminder list.
    public func createReminder(title: String, dueDate: Date?, notes: String? = nil) async throws -> String {
        let granted = await requestReminderAccess()
        guard granted else {
            throw NSError(
                domain: "EventKitManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Reminders ki permission nahi mili."]
            )
        }
        
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes ?? "Created by HinglishVoice Hinglish Voice Assistant"
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        if let dueDate = dueDate {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
            reminder.dueDateComponents = components
            
            let alarm = EKAlarm(absoluteDate: dueDate)
            reminder.addAlarm(alarm)
        }
        
        try eventStore.save(reminder, commit: true)
        return reminder.calendarItemIdentifier
    }
}
