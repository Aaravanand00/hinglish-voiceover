import Foundation

/// Reference dataset item for benchmarking and training reference.
public struct PhrasePatternItem: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let phrase: String
    public let phoneticVariants: [String]
    public let expectedCategory: IntentCategory
    public let expectedAction: SpecificAction
    public let exampleEntities: ExtractedEntities
    public let notes: String
    
    public init(
        id: String,
        phrase: String,
        phoneticVariants: [String] = [],
        expectedCategory: IntentCategory,
        expectedAction: SpecificAction,
        exampleEntities: ExtractedEntities = ExtractedEntities(),
        notes: String = ""
    ) {
        self.id = id
        self.phrase = phrase
        self.phoneticVariants = phoneticVariants
        self.expectedCategory = expectedCategory
        self.expectedAction = expectedAction
        self.exampleEntities = exampleEntities
        self.notes = notes
    }
}
