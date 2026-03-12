import Foundation
import SwiftUI
import Combine

/// Main ViewModel managing the state of the Hinglish Assistant, VoiceOver actions, and pipeline steps.
@MainActor
public final class AssistantViewModel: ObservableObject, NavigationDelegate {
    // Pipeline Services
    private let speechService: SpeechRecognizerService
    private let codeSwitchDetector: CodeSwitchDetector
    private let intentParser: HinglishIntentParser
    private let actionDispatcher: ActionDispatcher
    private let ttsService: TTSSpeechService
    
    // Published UI States
    @Published public var isListening: Bool = false
    @Published public var currentTranscript: String = ""
    @Published public var detectedTokens: [CodeSwitchToken] = []
    @Published public var lastParsedCommand: ParsedCommand?
    @Published public var executionStatusMessage: String = "Tap or use VoiceOver action to start speaking in Hinglish."
    @Published public var commandHistory: [ParsedCommand] = []
    @Published public var currentRoute: String = "home"
    @Published public var errorMessage: String?
    
    public init(
        speechService: SpeechRecognizerService = .shared,
        codeSwitchDetector: CodeSwitchDetector = .shared,
        intentParser: HinglishIntentParser = .shared,
        actionDispatcher: ActionDispatcher = .shared,
        ttsService: TTSSpeechService = .shared
    ) {
        self.speechService = speechService
        self.codeSwitchDetector = codeSwitchDetector
        self.intentParser = intentParser
        self.actionDispatcher = actionDispatcher
        self.ttsService = ttsService
    }
    
    // MARK: - Voice Command Flow
    
    /// Toggles listening on or off. VoiceOver users can invoke this via custom accessibility action.
    public func toggleListening() {
        if isListening {
            stopListeningAndProcess()
        } else {
            startListening()
        }
    }
    
    public func startListening() {
        errorMessage = nil
        currentTranscript = ""
        detectedTokens = []
        isListening = true
        executionStatusMessage = "Listening... (Aap bol sakte hain)"
        
        // Voice feedback prompt
        ttsService.speak(message: "Suniye, boliye...")
        
        Task {
            let authorized = await speechService.requestAuthorization()
            guard authorized else {
                self.isListening = false
                self.errorMessage = "Speech recognition permission denied."
                self.executionStatusMessage = "Kripya Settings me jakar Microphone aur Speech permissions enable karein."
                self.ttsService.speak(message: self.executionStatusMessage)
                return
            }
            
            do {
                try self.speechService.startListening(
                    onPartialResult: { [weak self] partialText in
                        Task { @MainActor in
                            self?.currentTranscript = partialText
                            self?.detectedTokens = self?.codeSwitchDetector.analyze(text: partialText) ?? []
                        }
                    },
                    onFinalResult: { [weak self] result in
                        Task { @MainActor in
                            switch result {
                            case .success(let finalTranscript):
                                self?.processTranscript(finalTranscript)
                            case .failure(let error):
                                self?.handleSpeechError(error)
                            }
                        }
                    }
                )
            } catch {
                self.handleSpeechError(error)
            }
        }
    }
    
    public func stopListeningAndProcess() {
        speechService.stopListening()
        isListening = false
        
        if !currentTranscript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            processTranscript(currentTranscript)
        } else {
            executionStatusMessage = "Koi awaz sunai nahi di. Kripya dobara boliye."
            ttsService.speak(message: executionStatusMessage)
        }
    }
    
    /// Processes a transcript string directly (usable by SpeechRecognizer or text simulator).
    public func processTranscript(_ text: String) {
        currentTranscript = text
        
        // Step 2: Code-Switch Detection
        let tokens = codeSwitchDetector.analyze(text: text)
        detectedTokens = tokens
        
        // Step 3: Intent Extraction
        let parsed = intentParser.parse(transcript: text)
        lastParsedCommand = parsed
        commandHistory.insert(parsed, at: 0)
        
        // Step 4: Action Execution
        Task {
            let (success, feedback) = await actionDispatcher.execute(command: parsed, navigationDelegate: self)
            self.executionStatusMessage = feedback
            
            // Step 5: VoiceOver Feedback & TTS
            self.ttsService.speak(message: feedback)
        }
    }
    
    private func handleSpeechError(_ error: Error) {
        isListening = false
        errorMessage = error.localizedDescription
        executionStatusMessage = "Awaz pehchanne me samasya aayi: \(error.localizedDescription)"
        ttsService.speak(message: executionStatusMessage)
    }
    
    // MARK: - NavigationDelegate
    
    public func navigate(to route: String) {
        self.currentRoute = route
    }
}
