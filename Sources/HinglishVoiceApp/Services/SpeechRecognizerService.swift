import Foundation
import Speech
import AVFoundation

/// Protocol defining the Speech Recognition Engine capability.
public protocol SpeechRecognizerServiceProtocol: AnyObject {
    var isListening: Bool { get }
    var currentTranscript: String { get }
    func requestAuthorization() async -> Bool
    func startListening(onPartialResult: @escaping (String) -> Void, onFinalResult: @escaping (Result<String, Error>) -> Void) throws
    func stopListening()
}

public enum SpeechRecognizerError: LocalizedError {
    case notAuthorized
    case recognizerUnavailable
    case audioEngineError(String)
    case onDeviceNotSupported
    
    public var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Microphone ya Speech Recognition ki permission nahi mili."
        case .recognizerUnavailable:
            return "Hinglish Speech Recognizer is samay uplabdh nahi hai."
        case .audioEngineError(let msg):
            return "Audio Engine error: \(msg)"
        case .onDeviceNotSupported:
            return "On-device speech recognition is device par supported nahi hai."
        }
    }
}

/// SFSpeechRecognizer implementation configured for on-device Hinglish recognition (hi-IN).
public final class SpeechRecognizerService: NSObject, SpeechRecognizerServiceProtocol, SFSpeechRecognizerDelegate, @unchecked Sendable {
    public static let shared = SpeechRecognizerService()
    
    private var speechRecognizer: SFSpeechRecognizer?
    private var fallbackRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    public private(set) var isListening: Bool = false
    public private(set) var currentTranscript: String = ""
    
    public override init() {
        super.init()
        // Primary: hi-IN (Hindi locale on iOS comfortably captures mixed Hindi-English words)
        self.speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "hi-IN"))
        // Fallback: en-IN (Indian English locale)
        self.fallbackRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-IN"))
        self.speechRecognizer?.delegate = self
    }
    
    public func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { authStatus in
                switch authStatus {
                case .authorized:
                    continuation.resume(returning: true)
                default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    public func startListening(
        onPartialResult: @escaping (String) -> Void,
        onFinalResult: @escaping (Result<String, Error>) -> Void
    ) throws {
        guard !isListening else { return }
        
        // Ensure authorization
        guard SFSpeechRecognizer.authorizationStatus() == .authorized else {
            throw SpeechRecognizerError.notAuthorized
        }
        
        let recognizer = (speechRecognizer?.isAvailable == true) ? speechRecognizer : fallbackRecognizer
        guard let recognizer = recognizer, recognizer.isAvailable else {
            throw SpeechRecognizerError.recognizerUnavailable
        }
        
        // Reset any previous tasks
        stopListening()
        
        // Configure Audio Session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.duckOthers, .defaultToSpeaker])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechRecognizerError.audioEngineError("Unable to create recognition request.")
        }
        
        // CRITICAL FOR ACCESSIBILITY & PRIVACY: Force on-device recognition
        if recognizer.supportsOnDeviceRecognition {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        isListening = true
        currentTranscript = ""
        
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let transcription = result.bestTranscription.formattedString
                self.currentTranscript = transcription
                onPartialResult(transcription)
                
                if result.isFinal {
                    self.stopListening()
                    onFinalResult(.success(transcription))
                }
            }
            
            if let error = error {
                self.stopListening()
                // If cancelled normally, don't treat as fatal error unless transcript is empty
                if (error as NSError).code != 216 || self.currentTranscript.isEmpty {
                    onFinalResult(.failure(error))
                } else {
                    onFinalResult(.success(self.currentTranscript))
                }
            }
        }
    }
    
    public func stopListening() {
        guard isListening else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        isListening = false
        
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // Handle dynamic availability change
    }
}
