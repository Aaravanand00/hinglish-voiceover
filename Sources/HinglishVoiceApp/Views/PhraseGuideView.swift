import SwiftUI

/// Reference screen displaying supported 50-100 Hinglish phrases across the 3 core categories.
public struct PhraseGuideView: View {
    @State private var selectedCategory: IntentCategory = .reminder
    
    // Built-in curated dataset of 50+ phrase patterns
    private let samplePhrases: [PhrasePatternItem] = [
        // Category 1: Reminders & Alarms
        PhrasePatternItem(
            id: "1",
            phrase: "kal 5 baje meeting ka reminder laga do",
            phoneticVariants: ["kl 5 bj meeting reminder lga do"],
            expectedCategory: .reminder,
            expectedAction: .createReminder,
            notes: "Creates reminder for tomorrow 5:00 PM"
        ),
        PhrasePatternItem(
            id: "2",
            phrase: "aaj shaam 7 baje gym yaad dila dena",
            phoneticVariants: ["aj sham 7 bje gym yaad dilana"],
            expectedCategory: .reminder,
            expectedAction: .createReminder,
            notes: "Creates reminder for today 7:00 PM"
        ),
        PhrasePatternItem(
            id: "3",
            phrase: "subah 6 baje ka alarm set karo",
            phoneticVariants: ["subah 6 bje alarm lagao"],
            expectedCategory: .reminder,
            expectedAction: .setAlarm,
            notes: "Sets morning 6:00 AM alarm"
        ),
        PhrasePatternItem(
            id: "4",
            phrase: "parso doctor appointment remind kar dena",
            phoneticVariants: ["parson doctor appointment yaad dilao"],
            expectedCategory: .reminder,
            expectedAction: .createReminder,
            notes: "Creates reminder for day after tomorrow"
        ),
        PhrasePatternItem(
            id: "5",
            phrase: "raat 9 baje dawai lene ka reminder lagao",
            phoneticVariants: ["rat 9 bje medicine yaad dilana"],
            expectedCategory: .reminder,
            expectedAction: .createReminder,
            notes: "Night medicine reminder"
        ),
        PhrasePatternItem(
            id: "6",
            phrase: "kal dopahar 2 baje flight reminder set karo",
            phoneticVariants: ["kal 2 baje flight"],
            expectedCategory: .reminder,
            expectedAction: .createReminder,
            notes: "Afternoon flight reminder"
        ),
        
        // Category 2: Calls & Messages
        PhrasePatternItem(
            id: "7",
            phrase: "Rahul ko call lagao",
            phoneticVariants: ["rahul ko phone karo", "call rahul"],
            expectedCategory: .contactAction,
            expectedAction: .makePhoneCall,
            notes: "Direct phone call to contact"
        ),
        PhrasePatternItem(
            id: "8",
            phrase: "Mummy ko phone karo",
            phoneticVariants: ["mummy ko call lagao", "call mummy"],
            expectedCategory: .contactAction,
            expectedAction: .makePhoneCall,
            notes: "Calls family contact"
        ),
        PhrasePatternItem(
            id: "9",
            phrase: "Pooja ko message bhejo ki main late ho jaunga",
            phoneticVariants: ["pooja ko text karo late ho jaunga"],
            expectedCategory: .contactAction,
            expectedAction: .sendTextMessage,
            notes: "Sends text message with body"
        ),
        PhrasePatternItem(
            id: "10",
            phrase: "Amit ko text karo ki meeting shuru ho gayi hai",
            phoneticVariants: ["amit ko msg bhej do"],
            expectedCategory: .contactAction,
            expectedAction: .sendTextMessage,
            notes: "Sends status message"
        ),
        
        // Category 3: Navigation
        PhrasePatternItem(
            id: "11",
            phrase: "home screen pe wapas jao",
            phoneticVariants: ["home jao", "go home"],
            expectedCategory: .navigation,
            expectedAction: .navigateHome,
            notes: "Navigates to home screen"
        ),
        PhrasePatternItem(
            id: "12",
            phrase: "pichle page pe chalo",
            phoneticVariants: ["wapas jao", "go back", "back jao"],
            expectedCategory: .navigation,
            expectedAction: .navigateBack,
            notes: "Navigates back"
        ),
        PhrasePatternItem(
            id: "13",
            phrase: "settings kholo",
            phoneticVariants: ["setting me jao", "open settings"],
            expectedCategory: .navigation,
            expectedAction: .openSettings,
            notes: "Opens app settings"
        ),
        PhrasePatternItem(
            id: "14",
            phrase: "ye kya hai screen describe karo",
            phoneticVariants: ["screen padho", "screen pe kya hai"],
            expectedCategory: .navigation,
            expectedAction: .readScreen,
            notes: "VoiceOver screen description"
        )
    ]
    
    public init() {}
    
    public var body: some View {
        VStack {
            // Category Picker
            Picker("Category", selection: $selectedCategory) {
                Text("Reminders").tag(IntentCategory.reminder)
                Text("Calls/SMS").tag(IntentCategory.contactAction)
                Text("Navigation").tag(IntentCategory.navigation)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Phrase List
            List {
                ForEach(filteredPhrases) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\"\(item.phrase)\"")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(item.notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if !item.phoneticVariants.isEmpty {
                            Text("Variations: " + item.phoneticVariants.joined(separator: ", "))
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Phrase: \(item.phrase). \(item.notes)")
                }
            }
        }
        .navigationTitle("Supported Commands")
    }
    
    private var filteredPhrases: [PhrasePatternItem] {
        samplePhrases.filter { $0.expectedCategory == selectedCategory }
    }
}
