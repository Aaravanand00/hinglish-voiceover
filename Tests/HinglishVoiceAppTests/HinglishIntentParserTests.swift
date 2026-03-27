import XCTest
@testable import HinglishVoice

final class HinglishIntentParserTests: XCTestCase {
    var parser: HinglishIntentParser!
    
    override func setUp() {
        super.setUp()
        parser = HinglishIntentParser()
    }
    
    // MARK: - Category 1: Reminders & Alarms Tests
    
    func testReminderWithDateAndTime() {
        let input = "kal 5 baje meeting ka reminder laga do"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .reminder)
        XCTAssertEqual(result.action, .createReminder)
        XCTAssertEqual(result.entities.dateString, "Kal (Tomorrow)")
        XCTAssertEqual(result.entities.targetHour, 17)
        XCTAssertEqual(result.entities.reminderTitle, "Meeting")
    }
    
    func testReminderPhoneticVariant() {
        let input = "kl 7 bje gym yaad dila dena"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .reminder)
        XCTAssertEqual(result.action, .createReminder)
        XCTAssertEqual(result.entities.dateString, "Kal (Tomorrow)")
        XCTAssertEqual(result.entities.targetHour, 19)
    }
    
    func testAlarmCommand() {
        let input = "subah 6 baje ka alarm set karo"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .reminder)
        XCTAssertEqual(result.action, .setAlarm)
        XCTAssertEqual(result.entities.targetHour, 6)
        XCTAssertEqual(result.entities.timeString, "06:00 AM")
    }
    
    func testReminderDayAfterTomorrow() {
        let input = "parso doctor appointment remind kar dena"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .reminder)
        XCTAssertEqual(result.action, .createReminder)
        XCTAssertEqual(result.entities.dateString, "Parso")
    }
    
    // MARK: - Category 2: Contact Actions (Call & Message) Tests
    
    func testMakePhoneCall() {
        let input = "Rahul ko call lagao"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .contactAction)
        XCTAssertEqual(result.action, .makePhoneCall)
        XCTAssertEqual(result.entities.contactName, "Rahul")
    }
    
    func testMakePhoneCallWithPrefix() {
        let input = "are bhai Mummy ko phone karo"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .contactAction)
        XCTAssertEqual(result.action, .makePhoneCall)
        XCTAssertEqual(result.entities.contactName, "Mummy")
    }
    
    func testSendTextMessageWithBody() {
        let input = "Pooja ko message bhejo ki main late ho jaunga"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .contactAction)
        XCTAssertEqual(result.action, .sendTextMessage)
        XCTAssertEqual(result.entities.contactName, "Pooja")
        XCTAssertEqual(result.entities.messageContent, "main late ho jaunga")
    }
    
    // MARK: - Category 3: Navigation Tests
    
    func testNavigateHome() {
        let input = "home screen pe wapas jao"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .navigation)
        XCTAssertEqual(result.action, .navigateHome)
        XCTAssertEqual(result.entities.navigationTarget, "home")
    }
    
    func testNavigateBack() {
        let input = "pichle page pe chalo"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .navigation)
        XCTAssertEqual(result.action, .navigateBack)
        XCTAssertEqual(result.entities.navigationTarget, "back")
    }
    
    func testOpenSettings() {
        let input = "settings kholo"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .navigation)
        XCTAssertEqual(result.action, .openSettings)
        XCTAssertEqual(result.entities.navigationTarget, "settings")
    }
    
    func testReadScreen() {
        let input = "ye kya hai screen describe karo"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .navigation)
        XCTAssertEqual(result.action, .readScreen)
    }
    
    // MARK: - Unknown & Fallback Tests
    
    func testUnknownInput() {
        let input = "kuch bhi ajeeb sa sentence"
        let result = parser.parse(transcript: input)
        
        XCTAssertEqual(result.category, .unknown)
        XCTAssertFalse(result.isExecutable)
    }
}
