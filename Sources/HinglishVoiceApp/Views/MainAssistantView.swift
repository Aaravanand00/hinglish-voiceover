import SwiftUI

/// Primary VoiceOver-optimized Assistant Interface.
public struct MainAssistantView: View {
    @StateObject private var viewModel = AssistantViewModel()
    @State private var selectedTab: Int = 0
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header / App Title
                VStack(spacing: 6) {
                    Text("Hinglish Voice Assistant")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.primary)
                    
                    Text("VoiceOver Hinglish Assistant")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("HinglishVoice, VoiceOver Hinglish Assistant")
                
                Spacer()
                
                // Status Feedback Banner
                VStack(spacing: 8) {
                    Text(viewModel.executionStatusMessage)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(viewModel.isListening ? .red : .primary)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(viewModel.executionStatusMessage)
                
                // Latest Parsed Command Card if available
                if let command = viewModel.lastParsedCommand {
                    IntentResultCard(command: command, tokens: viewModel.detectedTokens)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Primary Accessible Microphone Action
                AccessibleMicButton(isListening: viewModel.isListening) {
                    viewModel.toggleListening()
                }
                .padding(.bottom, 10)
                
                // Secondary Accessibility Actions & Quick Links
                HStack(spacing: 20) {
                    NavigationLink(destination: PhraseGuideView()) {
                        Label("Commands Guide", systemImage: "book.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .accessibilityHint("Supported 50-100 Hinglish phrases ki list dekhein")
                    
                    NavigationLink(destination: TestSimulatorView(viewModel: viewModel)) {
                        Label("Test Simulator", systemImage: "keyboard")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .accessibilityHint("Hinglish phrases type karke test karein")
                }
                .padding(.bottom, 20)
            }
            .padding()
            .navigationBarHidden(true)
            // VoiceOver Custom Actions: Allows activating HinglishVoice from anywhere on the screen
            .accessibilityAction(named: "Toggle Hinglish Voice Command") {
                viewModel.toggleListening()
            }
        }
    }
}
