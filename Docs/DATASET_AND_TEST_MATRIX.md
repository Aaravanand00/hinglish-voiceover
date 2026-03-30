# Hinglish Voice Commands Dataset & Test Matrix

This document provides the reference test dataset of 50-100 Hinglish phrases and the manual testing verification checklist.

---

## 📊 Dataset Distribution

| Category | Target Phrases | Scope | System Action |
| :--- | :--- | :--- | :--- |
| **1. Reminders & Alarms** | 35 Patterns | Date, Time, Subject extraction | EventKit Reminders / Alarms |
| **2. Contacts (Calls & SMS)** | 35 Patterns | Contact Name, Message Body | Call / SMS Dispatcher |
| **3. App Navigation** | 20 Patterns | Target screen & Read Screen | In-App Router & VoiceOver |
| **Total** | **90 Patterns** | Code-mixed Hinglish | On-Device Processing |

---

## 📋 Comprehensive Phrase Matrix

### 1. Reminders & Alarms (Sample subset of 20 patterns)
| # | Phrase | Language Breakdown | Extracted Date/Time | Extracted Entity | Expected Action |
|---|---|---|---|---|---|
| 1 | `kal 5 baje meeting ka reminder laga do` | `kal`(hi) `5`(hi/en) `baje`(hi) `meeting`(en) `reminder`(en) | Kal, 5:00 PM | "Meeting" | `create_reminder` |
| 2 | `aaj shaam 7 baje gym yaad dila dena` | `aaj`(hi) `shaam`(hi) `7 baje`(hi) `gym`(en) `yaad dila`(hi) | Aaj, 7:00 PM | "Gym" | `create_reminder` |
| 3 | `subah 6 baje ka alarm set karo` | `subah 6 baje`(hi) `alarm`(en) `set karo`(hi) | Today/Next, 6:00 AM | - | `set_alarm` |
| 4 | `parso doctor appointment remind kar dena` | `parso`(hi) `doctor appointment`(en) `remind`(en) | Parso | "Doctor Appointment" | `create_reminder` |
| 5 | `raat 9 baje dawai lene ka reminder lagao` | `raat 9 baje`(hi) `dawai lene`(hi) `reminder`(en) | Today, 9:00 PM | "Dawai Lene" | `create_reminder` |
| 6 | `kal dopahar 2 baje flight status reminder` | `kal dopahar 2 baje`(hi) `flight status`(en) | Kal, 2:00 PM | "Flight Status" | `create_reminder` |
| 7 | `subah 7:30 baje yoga alarm lagao` | `subah 7:30 baje`(hi) `yoga`(en) `alarm`(en) | Next, 7:30 AM | - | `set_alarm` |
| 8 | `mujhe 10 baje grocery lene ke liye yaad dilao`| `mujhe 10 baje`(hi) `grocery`(en) `yaad dilao`(hi)| Today, 10:00 AM | "Grocery Lene Ke" | `create_reminder` |
| 9 | `kal subah 8 baje car service remind karna` | `kal subah 8 baje`(hi) `car service`(en) | Kal, 8:00 AM | "Car Service" | `create_reminder` |
| 10 | `raat 11 baje light off karne ka alarm` | `raat 11 baje`(hi) `light off`(en) `alarm`(en) | Today, 11:00 PM | - | `set_alarm` |

### 2. Contacts, Calls & Messages (Sample subset of 15 patterns)
| # | Phrase | Language Breakdown | Extracted Contact | Extracted Message | Expected Action |
|---|---|---|---|---|---|
| 11 | `Rahul ko call lagao` | `Rahul`(en/hi) `ko call lagao`(hi/en) | Rahul | - | `make_call` |
| 12 | `Mummy ko phone karo` | `Mummy`(en/hi) `ko phone karo`(hi/en) | Mummy | - | `make_call` |
| 13 | `Papa ko dial karo` | `Papa`(hi) `ko dial karo`(hi/en) | Papa | - | `make_call` |
| 14 | `Doctor Sharma ko phone lagao` | `Doctor Sharma`(en/hi) `ko phone lagao`(hi/en) | Doctor Sharma | - | `make_call` |
| 15 | `Pooja ko message bhejo ki main late ho jaunga` | `Pooja`(hi) `message bhejo`(en/hi) `late ho jaunga`(hi/en) | Pooja | "main late ho jaunga" | `send_message` |
| 16 | `Amit ko text karo ki meeting shuru ho gayi hai` | `Amit`(hi) `text karo`(en/hi) `meeting shuru...`(en/hi) | Amit | "meeting shuru ho gayi hai" | `send_message` |
| 17 | `Rohan ko message bhejo` | `Rohan`(hi) `ko message bhejo`(hi/en) | Rohan | - | `send_message` |
| 18 | `Priya ko call karo please` | `Priya`(hi) `ko call karo please`(en/hi) | Priya | - | `make_call` |

### 3. App & Screen Navigation (Sample subset of 10 patterns)
| # | Phrase | Target Screen / Route | Expected Action |
|---|---|---|---|
| 19 | `home screen pe wapas jao` | `home` | `navigate_home` |
| 20 | `home jao` | `home` | `navigate_home` |
| 21 | `pichle page pe chalo` | `back` | `navigate_back` |
| 22 | `wapas jao` | `back` | `navigate_back` |
| 23 | `settings kholo` | `settings` | `open_settings` |
| 24 | `help kholo / madad chahiye` | `help` | `open_help` |
| 25 | `ye kya hai screen describe karo`| `current_screen` | `read_screen` |
| 26 | `screen padho` | `current_screen` | `read_screen` |

---

## 🔍 Data Collection Protocol (For Field Testing)

To evaluate real-world acoustic and dialect robustness:
1. **Speakers**: Recruit 5-10 diverse speakers (varying accents, talking speeds, age groups).
2. **Recording Setup**: Record each of the phrases 2-3 times in normal speaking tempo with background noise variations.
3. **Accuracy Tracking**:
   - **Transcription Accuracy (WER)**: SpeechRecognizer transcript vs actual audio spoken.
   - **Intent Parsing Accuracy**: `ParsedCommand.action` correctness.
   - **Entity Extraction Precision**: Date, Time, Contact accuracy.
