# Hinglish Voice Assistant - Hinglish Voice Assistant for VoiceOver

> **An On-Device, Privacy-First Bilingual Voice Command Engine tailored for Visually Impaired and VoiceOver Users in India.**

---

## 📌 Problem Statement

In India, hundreds of millions of people speak in **Hinglish** (a seamless code-switching mix of Hindi and English) as their primary everyday language:
- *"kal subah 7 baje gym ka reminder laga do"*
- *"Rahul ko call lagao"*
- *"Home screen pe wapas jao"*

However, existing Voice Assistants (Apple Siri, standard Speech Recognition APIs) are trained primarily on monolingual datasets (either pure English or pure Hindi). When users code-switch mid-sentence:
1. **Speech-to-Text Fails**: Phonetic transcriptions drop Hindi inflections or misspell English loanwords.
2. **Intent Parsing Breaks**: Grammatical word orders (Subject-Object-Verb in Hindi vs. Subject-Verb-Object in English) confuse standard intent extractors.
3. **Accessibility Gap**: For blind and visually impaired users who rely 100% on **VoiceOver**, a failed voice command is not a minor inconvenience - it is a complete barrier to device usage.

---

## 🚀 Solution Architecture

HinglishVoice provides an on-device, low-latency 5-step processing pipeline:

```
[User Voice Input (Hinglish)]
          │
          ▼
┌────────────────────────────────────────────────────────┐
│ Step 1: Speech-to-Text (SFSpeechRecognizer)            │
│ • Locale: hi-IN (handles Hindi & English loanwords)   │
│ • supportsOnDeviceRecognition = true (100% Offline)    │
└─────────────────────────┬──────────────────────────────┘
                          │ Raw Transcript
                          ▼
┌────────────────────────────────────────────────────────┐
│ Step 2: Code-Switch Detection (NLLanguageRecognizer)   │
│ • Word-level Language Tagging (hi / en)                │
│ • Transliteration Normalization                        │
└─────────────────────────┬──────────────────────────────┘
                          │ Tagged Tokens
                          ▼
┌────────────────────────────────────────────────────────┐
│ Step 3: Hinglish Intent Engine (50-100 Patterns)       │
│ • Pattern Matching across 3 Core Categories:           │
│   1. Reminders & Alarms (EventKit)                     │
│   2. Contact Actions (Calls & Messages)                │
│   3. Navigation (In-App & Accessibility Routes)        │
│ • Slot / Entity Extraction (Time, Date, Contact, Route)│
└─────────────────────────┬──────────────────────────────┘
                          │ Extracted Intent & Entities
                          ▼
┌────────────────────────────────────────────────────────┐
│ Step 4: Action Execution                               │
│ • EventKit: Creates actual iOS Reminders/Alarms        │
│ • URL Dispatch: tel:// & sms:// handles                │
│ • In-App Navigation Router                             │
└─────────────────────────┬──────────────────────────────┘
                          │ Status Result
                          ▼
┌────────────────────────────────────────────────────────┐
│ Step 5: VoiceOver Accessible Feedback                  │
│ • UIAccessibility.post(announcement)                   │
│ • AVSpeechSynthesizer bilingual audio feedback         │
│ • High-contrast, large-target Accessible UI            │
└────────────────────────────────────────────────────────┘
```

---

## 📂 Project Structure

```
HinglishVoiceApp/
├── README.md                          # Project Documentation
├── Package.swift                      # SPM Manifest for builds & unit testing
├── Sources/
│   └── HinglishVoiceApp/
│       ├── HinglishVoiceApp.swift          # App Entry & Root Setup
│       ├── Models/
│       │   ├── CommandIntent.swift    # Core Intent Enums & Models
│       │   ├── ExtractedEntity.swift  # Time, Date, Contact, Target slots
│       │   ├── CodeSwitchToken.swift  # Word-level Language Tag model
│       │   └── PhrasePattern.swift    # Dataset structure
│       ├── Services/
│       │   ├── SpeechRecognizerService.swift # SFSpeechRecognizer on-device engine
│       │   ├── CodeSwitchDetector.swift      # NLLanguageRecognizer bilingual tagger
│       │   ├── HinglishIntentParser.swift    # 50-100 pattern parser & slot extractor
│       │   ├── EventKitManager.swift         # iOS Reminders & EventKit handler
│       │   ├── ActionDispatcher.swift        # Action router (Call, SMS, Nav, Reminder)
│       │   └── TTSSpeechService.swift        # VoiceOver & TTS Confirmation engine
│       ├── ViewModels/
│       │   └── AssistantViewModel.swift      # Observable ViewModel connecting UI to Services
│       ├── Views/
│       │   ├── MainAssistantView.swift       # VoiceOver-optimized main screen
│       │   ├── PhraseGuideView.swift         # Interactive library of 50-100 phrases
│       │   ├── TestSimulatorView.swift       # Text & Audio simulator for instant testing
│       │   └── Components/
│       │       ├── AccessibleMicButton.swift # Custom accessibility gesture button
│       │       └── IntentResultCard.swift    # Visual card for parsed intents
│       └── Resources/
│           ├── HinglishPhrasesDataset.json   # 75+ Reference Hinglish phrases with ground truth
│           └── Info.plist                    # Microphone & Speech Privacy declarations
├── Tests/
│   └── HinglishVoiceAppTests/
│       ├── HinglishIntentParserTests.swift   # Unit tests for intent parsing
│       ├── CodeSwitchDetectorTests.swift     # Unit tests for bilingual tagging
│       └── EndToEndFlowTests.swift           # Pipeline integration tests
└── Docs/
    ├── ARCHITECTURE.md                       # Deep technical breakdown
    ├── DATASET_AND_TEST_MATRIX.md            # Phrase dataset & verification matrix
    └── ACCESSIBILITY_GUIDELINES.md           # VoiceOver design rules
```

---

## 🎯 3 Supported Intent Categories (50-100 Phrases)

### 1. Reminders & Alarms
- *"kal 5 baje meeting ka reminder laga do"*
- *"aaj shaam 7 baje gym yaad dila dena"*
- *"subah 6 baje ka alarm set karo"*
- *"parso doctor appointment remind kar dena"*

### 2. Contacts, Calls & Messages
- *"Rahul ko call lagao"*
- *"Mummy ko phone karo"*
- *"Pooja ko message bhejo ki main late ho jaunga"*
- *"Amit ko text kar do"*

### 3. In-App & System Navigation
- *"home screen pe wapas jao"*
- *"settings kholo"*
- *"pichle page pe chalo"*
- *"ye kya hai / screen padho"*

---

## 🧪 Testing & Verification

1. **Unit Tests**: Run tests via Swift Package Manager:
   ```bash
   swift test
   ```
2. **Interactive Simulator**:
   Open the in-app **Test Harness (Simulator)** to type or speak any Hinglish sentence and inspect:
   - Word-by-word code-switch tagging (`hi` vs `en`).
   - Parsed intent category and extracted parameters (date, time, contact name, message body).
   - Executed action and VoiceOver announcement response.
