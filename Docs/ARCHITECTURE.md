# HinglishVoice - Technical Architecture Specification

## 1. System Overview

HinglishVoice is an on-device, code-mixed (Hinglish) voice command processing engine for iOS designed for accessibility, specifically empowering VoiceOver users.

```
┌─────────────────────────────────────────────────────────────┐
│                     USER VOICE INPUT                        │
│          ("kal 5 baje meeting ka reminder laga do")         │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 1: Speech-to-Text Layer (Speech.framework)             │
│ • SFSpeechRecognizer(locale: "hi-IN")                       │
│ • Fallback: Locale "en-IN"                                  │
│ • requiresOnDeviceRecognition = true                        │
│ • Output: Raw Transcript String                             │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 2: Code-Switch Detection (NaturalLanguage.framework)   │
│ • NLTokenizer (Word-level unit)                             │
│ • NLLanguageRecognizer + Custom Romanized Lexicon           │
│ • Output: [CodeSwitchToken(word, langTag: hi/en, conf)]     │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 3: Intent & Entity Parser (HinglishIntentParser)       │
│ • Transliteration Normalizer                                │
│ • 50-100 Predefined Hinglish Phrase Matchers                │
│ • Regex & Slot Extractors (Date, Time, Contact, Message)    │
│ • Output: ParsedCommand(category, action, entities)         │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 4: Action Execution Layer                              │
│ • EventKit: EKEventStore (Reminders & Alarms)               │
│ • Communication: URL Schemes (tel://, sms://)               │
│ • Navigation: In-App Accessibility Router                   │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│ Step 5: Dual Feedback System                                │
│ • UIAccessibility.post(notification: .announcement)         │
│ • AVSpeechSynthesizer (hi-IN / en-IN vocal confirmation)    │
│ • High-Contrast, VoiceOver rotor-compatible UI Cards        │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. Component Breakdown

### 2.1 Speech Recognizer Service (`SpeechRecognizerService.swift`)
- **Framework**: `Speech` + `AVFAudio`.
- **Locale Selection**: `hi-IN` (Hindi-India) is used because its acoustic model and language model accommodate phonetic Hindi structures while recognizing English loanwords commonly used in Indian urban contexts.
- **On-Device Enforcement**: `recognitionRequest.requiresOnDeviceRecognition = true` guarantees zero network lag and privacy.

### 2.2 Code-Switching Detection (`CodeSwitchDetector.swift`)
- Uses `NLTokenizer` to extract words.
- Employs a dual approach:
  1. Devanagari range detector (0x0900 - 0x097F) -> 100% Hindi.
  2. Curated Romanized Hindi phonetic dictionary (kal, baje, yaad, dila, etc.) -> Hindi.
  3. `NLLanguageRecognizer` confidence scores for ambiguous tokens.

### 2.3 Intent & Entity Engine (`HinglishIntentParser.swift`)
- Cleans and normalizes transcript variations (e.g. "kl" -> "kal", "bj" -> "baje", "fon" -> "phone").
- Categorizes utterances into 3 core domains:
  1. **Reminders & Alarms**: Parses relative dates (aaj, kal, parso) and 12/24 hour times (5 baje, subah 7:30, shaam 6 baje).
  2. **Contacts, Calls & Messages**: Extracts recipient ("Rahul ko call", "Pooja ko text") and message bodies ("ki main late ho jaunga").
  3. **Navigation**: Identifies screen routes (home, back, settings, help, read screen).

### 2.4 Action Dispatcher (`ActionDispatcher.swift` & `EventKitManager.swift`)
- Handles asynchronous creation of `EKReminder` entries with specific `EKAlarm` trigger timestamps.
- Integrates with system-level intents and internal application routes.

### 2.5 VoiceOver Accessibility & Audio Engine (`TTSSpeechService.swift`)
- Coordinates with `UIAccessibility` system notifications.
- Speaks natural bilingual feedback using `AVSpeechSynthesisVoice(language: "hi-IN")` with optimal speech rate for screen-reader users.
