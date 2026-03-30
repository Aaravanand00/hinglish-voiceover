# Accessibility & VoiceOver Integration Guidelines

This document details the accessibility standards implemented in HinglishVoice for blind and visually impaired users.

---

## 1. VoiceOver Navigation & Custom Actions

### Screen-Wide Custom Accessibility Actions
- Standard voice assistants often require visually locating and tapping small microphone buttons.
- In HinglishVoice, the root view registers a `UIAccessibilityCustomAction`:
  ```swift
  .accessibilityAction(named: "Toggle Hinglish Voice Command") {
      viewModel.toggleListening()
  }
  ```
  This enables VoiceOver users to swipe down with one finger (or use the Accessibility Rotor) anywhere on the screen to instantly trigger listening without needing to hunt for the microphone icon.

---

## 2. Audio & Speech Feedback Hierarchy

To ensure screen-reader users are never left wondering whether the app heard them:

1. **Activation Feedback**:
   - Audio prompt + Haptic trigger ("Suniye, boliye...").
2. **Real-time VoiceOver Announcement**:
   - `UIAccessibility.post(notification: .announcement, argument: feedbackText)`
   - Guarantees VoiceOver reads the parsed action immediately over other UI elements.
3. **Natural Bilingual TTS Confirmation**:
   - `AVSpeechSynthesizer` with `hi-IN` Hindi voice.
   - Example: *"Theek hai, kal subah 7:00 AM gym ka reminder set kar diya gaya hai."*

---

## 3. Visual High-Contrast Design

- **Touch Target Size**: Minimum 60×60 pt (HinglishVoice mic button is 90×90 pt).
- **Color Contrast**: 7:1 ratio (WCAG AAA compliant) for text labels and dynamic states.
- **Dynamic Type**: Fully scales with iOS system text size settings.
