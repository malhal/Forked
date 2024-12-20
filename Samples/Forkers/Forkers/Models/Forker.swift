import Foundation
import ForkedModel
import ForkedMerge
import Forked

/// How much a Forker owes you.
struct Balance: Mergeable, Codable, Hashable {
    var dollarAmount: Float = 0.0
    func merged(withSubordinate other: Self, commonAncestor: Self) throws -> Self {
        Self(dollarAmount: dollarAmount + other.dollarAmount - commonAncestor.dollarAmount)
    }
}

@ForkedModel
struct Forkers: Codable {
    @Merged(using: .arrayOfIdentifiableMerge) var forkers: [Forker] = []
}

@ForkedModel
struct Forker: Identifiable, Codable, Hashable {
    var id: UUID = .init()
    var firstName: String = ""
    var lastName: String = ""
    var company: String = ""
    var birthday: Date?
    var email: String = ""
    var category: ForkerCategory?
    var color: ForkerColor?
    @Merged var balance: Balance = .init()
    @Merged var notes: String = ""
    @Merged var tags: Set<String> = []
}
