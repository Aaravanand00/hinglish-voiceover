import XCTest
@testable import HinglishVoice

final class CodeSwitchDetectorTests: XCTestCase {
    var detector: CodeSwitchDetector!
    
    override func setUp() {
        super.setUp()
        detector = CodeSwitchDetector()
    }
    
    func testBilingualTokenClassification() {
        let input = "kal 5 baje meeting ka reminder laga do"
        let tokens = detector.analyze(text: input)
        
        XCTAssertFalse(tokens.isEmpty)
        
        let tokenMap = Dictionary(uniqueKeysWithValues: tokens.map { ($0.word.lowercased(), $0.languageTag) })
        
        // "kal", "baje", "ka", "laga", "do" should be Hindi
        XCTAssertEqual(tokenMap["kal"], .hindi)
        XCTAssertEqual(tokenMap["baje"], .hindi)
        XCTAssertEqual(tokenMap["laga"], .hindi)
        
        // "meeting", "reminder" should be English
        XCTAssertEqual(tokenMap["meeting"], .english)
        XCTAssertEqual(tokenMap["reminder"], .english)
    }
    
    func testDevanagariDetection() {
        let input = "नमस्ते meeting"
        let tokens = detector.analyze(text: input)
        
        let namasteToken = tokens.first { $0.word == "नमस्ते" }
        XCTAssertNotNil(namasteToken)
        XCTAssertEqual(namasteToken?.languageTag, .hindi)
    }
    
    func testCodeSwitchRatio() {
        let input = "kal meeting hai"
        let tokens = detector.analyze(text: input)
        let ratio = detector.codeSwitchRatio(tokens: tokens)
        
        XCTAssertGreaterThan(ratio.hindiRatio, 0)
        XCTAssertGreaterThan(ratio.englishRatio, 0)
    }
}
