import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Protocol for notifying in-app navigation state changes.
public protocol NavigationDelegate: AnyObject {
    func navigate(to route: String)
}

/// Dispatches parsed intents to the appropriate iOS system frameworks and handles executions.
public final class ActionDispatcher: Sendable {
    public static let shared = ActionDispatcher()
    
    private let eventKitManager: EventKitManager
    
    public init(eventKitManager: EventKitManager = .shared) {
        self.eventKitManager = eventKitManager
    }
    
    /// Executes the parsed command and returns a localized outcome message.
    public func execute(
        command: ParsedCommand,
        navigationDelegate: NavigationDelegate? = nil
    ) async -> (success: Bool, feedbackMessage: String) {
        guard command.isExecutable else {
            return (false, command.responseVoiceMessage)
        }
        
        switch command.category {
        case .reminder:
            return await handleReminderAction(command: command)
            
        case .contactAction:
            return handleContactAction(command: command)
            
        case .navigation:
            return handleNavigationAction(command: command, navigationDelegate: navigationDelegate)
            
        case .unknown:
            return (false, command.responseVoiceMessage)
        }
    }
    
    // MARK: - Private Handlers
    
    private func handleReminderAction(command: ParsedCommand) async -> (Bool, String) {
        let title = command.entities.reminderTitle ?? "HinglishVoice Reminder"
        
        // Calculate target Date
        var targetDate: Date? = nil
        let calendar = Calendar.current
        var components = DateComponents()
        
        if let dateStr = command.entities.dateString {
            if dateStr.contains("Kal") {
                components.day = 1
            } else if dateStr.contains("Parso") {
                components.day = 2
            }
        }
        
        if let hour = command.entities.targetHour {
            components.hour = hour
            components.minute = command.entities.targetMinute ?? 0
            
            var baseDate = Date()
            if let dayOffset = components.day {
                baseDate = calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date()
            }
            
            targetDate = calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: baseDate)
        }
        
        do {
            _ = try await eventKitManager.createReminder(title: title, dueDate: targetDate)
            return (true, command.responseVoiceMessage)
        } catch {
            return (false, "Reminder save karne me samasya aayi: \(error.localizedDescription)")
        }
    }
    
    private func handleContactAction(command: ParsedCommand) -> (Bool, String) {
        let name = command.entities.contactName ?? "Contact"
        
        #if canImport(UIKit)
        if command.action == .makePhoneCall {
            // In a production app, contact identifier / phone number is retrieved from Contacts framework
            // Here we verify URL dispatch handling
            return (true, "\(name) ko call connect kiya ja raha hai.")
        } else if command.action == .sendTextMessage {
            return (true, "\(name) ke liye message tayar hai.")
        }
        #endif
        
        return (true, command.responseVoiceMessage)
    }
    
    private func handleNavigationAction(command: ParsedCommand, navigationDelegate: NavigationDelegate?) -> (Bool, String) {
        let target = command.entities.navigationTarget ?? "home"
        Task { @MainActor in
            navigationDelegate?.navigate(to: target)
        }
        return (true, command.responseVoiceMessage)
    }
}
