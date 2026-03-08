import Foundation
import AVFoundation
#if canImport(UIKit)
import UIKit
#endif

/// Service handling Text-to-Speech audio confirmations and VoiceOver system announcements.
public final class TTSSpeechService: NSObject, AVSpeechSynthesizerDelegate, @unchecked Sendable {
    public static let shared = TTSSpeechService()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var isSpeakingState: Bool = false
    
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    /// Speaks a confirmation message in natural Indian bilingual tone and triggers VoiceOver announcement.
    public func speak(message: String, completion: (@Sendable () -> Void)? = nil) {
        guard !message.isEmpty else {
            completion?()
            return
        }
        
        // 1. VoiceOver Screen Reader Announcement
        #if canImport(UIKit)
        UIAccessibility.post(notification: .announcement, argument: message)
        #endif
        
        // 2. AVSpeechSynthesizer Audio Feedback
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: message)
        
        // Prefer Indian Hindi voice (hi-IN) or Indian English voice (en-IN)
        if let hindiVoice = AVSpeechSynthesisVoice(language: "hi-IN") {
            utterance.voice = hindiVoice
        } else if let enInVoice = AVSpeechSynthesisVoice(language: "en-IN") {
            utterance.voice = enInVoice
        } else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.95 // Slightly slower for clarity
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    /// Stops any active speech output.
    public func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeakingState = false
    }
}
