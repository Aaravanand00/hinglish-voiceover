import SwiftUI

/// Accessible microphone button designed for VoiceOver and high-contrast accessibility.
public struct AccessibleMicButton: View {
    let isListening: Bool
    let action: () -> Void
    
    public init(isListening: Bool, action: @escaping () -> Void) {
        self.isListening = isListening
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isListening ? Color.red : Color.blue)
                    .frame(width: 90, height: 90)
                    .shadow(color: isListening ? Color.red.opacity(0.4) : Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                
                Image(systemName: isListening ? "stop.fill" : "mic.fill")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isListening ? "Hinglish voice command stop karein" : "Hinglish voice command bolna shuru karein")
        .accessibilityHint("Double tap karke Hinglish me command bolein jaise 'kal 5 baje reminder laga do' ya 'Rahul ko call karo'")
        .accessibilityAddTraits(.isButton)
    }
}
