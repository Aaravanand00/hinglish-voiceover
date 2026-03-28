import XCTest
@testable import HinglishVoice

final class EndToEndFlowTests: XCTestCase {
    var intentParser: HinglishIntentParser!
    var codeSwitchDetector: CodeSwitchDetector!
    
    override func setUp() {
        super.setUp()
        intentParser = HinglishIntentParser()
        codeSwitchDetector = CodeSwitchDetector()
    }
    
    func testEndToEndPipelineParsing() {
        let testPhrases = [
            ("kal 5 baje meeting ka reminder laga do", IntentCategory.reminder),
            ("Rahul ko call lagao", IntentCategory.contactAction),
            ("Pooja ko message bhejo ki main late ho jaunga", IntentCategory.contactAction),
            ("home screen pe wapas jao", IntentCategory.navigation),
            ("subah 6 baje ka alarm set karo", IntentCategory.reminder),
            ("settings kholo", IntentCategory.navigation),
            ("pichle page pe chalo", IntentCategory.navigation)
        ]
        
        for (phrase, expectedCategory) in testPhrases {
            // Step 1: Tokenize and detect code-switching
            let tokens = codeSwitchDetector.analyze(text: phrase)
            XCTAssertFalse(tokens.isEmpty, "Tokens should not be empty for '\(phrase)'")
            
            // Step 2: Parse intent
            let parsed = intentParser.parse(transcript: phrase)
            XCTAssertEqual(parsed.category, expectedCategory, "Phrase '\(phrase)' should match category \(expectedCategory)")
            XCTAssertTrue(parsed.isExecutable, "Phrase '\(phrase)' should be executable")
            XCTAssertFalse(parsed.responseVoiceMessage.isEmpty, "Response voice message should not be empty")
        }
    }
}
