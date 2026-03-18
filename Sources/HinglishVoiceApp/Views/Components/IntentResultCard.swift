import SwiftUI

/// Visual & VoiceOver-accessible card presenting parsed intent details and code-switch tokens.
public struct IntentResultCard: View {
    let command: ParsedCommand
    let tokens: [CodeSwitchToken]
    
    public init(command: ParsedCommand, tokens: [CodeSwitchToken]) {
        self.command = command
        self.tokens = tokens
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category & Action Header
            HStack {
                Text(command.category.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(String(format: "%.0f%% Match", command.confidence * 100))
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
                    .cornerRadius(8)
            }
            
            // Raw Utterance
            VStack(alignment: .leading, spacing: 4) {
                Text("Spoken Command:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\"\(command.rawTranscript)\"")
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            // Code-Switch Tags Pill View
            if !tokens.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Code-Switch Language Tags:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tokens) { token in
                                HStack(spacing: 4) {
                                    Text(token.word)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Text("(\(token.languageTag.rawValue))")
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(tokenColor(for: token.languageTag))
                                .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            // Extracted Entities
            VStack(alignment: .leading, spacing: 6) {
                Text("Extracted Parameters:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let contact = command.entities.contactName {
                    EntityRow(label: "Contact", value: contact)
                }
                if let title = command.entities.reminderTitle {
                    EntityRow(label: "Reminder Title", value: title)
                }
                if let date = command.entities.dateString {
                    EntityRow(label: "Date", value: date)
                }
                if let time = command.entities.timeString {
                    EntityRow(label: "Time", value: time)
                }
                if let target = command.entities.navigationTarget {
                    EntityRow(label: "Nav Route", value: target)
                }
                if let msg = command.entities.messageContent {
                    EntityRow(label: "Message Body", value: msg)
                }
            }
            
            // Feedback voice message
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.blue)
                Text(command.responseVoiceMessage)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
            .padding(8)
            .background(Color.blue.opacity(0.08))
            .cornerRadius(8)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(command.category.rawValue), command: \(command.rawTranscript), result: \(command.responseVoiceMessage)")
    }
    
    private func tokenColor(for tag: DetectedLanguageTag) -> Color {
        switch tag {
        case .hindi: return Color.orange.opacity(0.2)
        case .english: return Color.blue.opacity(0.2)
        case .mixedOrNeutral: return Color.gray.opacity(0.2)
        }
    }
}

private struct EntityRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(.caption)
                .fontWeight(.bold)
            Text(value)
                .font(.caption)
            Spacer()
        }
    }
}
