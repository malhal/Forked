import Testing
@testable import Forked

struct Pair: Equatable, Mergable {
    var a: Int
    var b: Int

    func merged(withOlderConflicting other: Pair, commonAncestor: Pair?) throws -> Pair {
        guard let commonAncestor else { return self }
        var result = self
        if self.a == commonAncestor.a && other.a != commonAncestor.a {
            result.a = other.a
        }
        if self.b == commonAncestor.b && other.b != commonAncestor.b {
            result.b = other.b
        }
        return result
    }
    
}

struct MergingMergableSuite {
    typealias Repo = AtomicRepository<Pair>
    let repo = AtomicRepository<Pair>()
    let resource: ForkedResource<AtomicRepository<Pair>>
    let fork = Fork(name: "fork")
    
    init() throws {
        resource = try ForkedResource(repository: repo)
        try resource.create(fork)
    }
    
    @Test func mergeWithTwoNone() throws {
        let p = Pair(a: 1, b: 2)
        try resource.update(.main, with: p)
        try resource.mergeFromMain(into: fork)
        let r = try resource.mostRecentCommit(of: fork).content.resource
        #expect(r == p)
    }
    
    @Test func mergeWithNone() throws {
        let p1 = Pair(a: 1, b: 2)
        try resource.update(.main, with: p1)
        try resource.update(fork, with: .none)
        try #require(resource.mergeFromMain(into: fork) == .resolveConflict)
        let r = try resource.mostRecentCommit(of: fork).content.resource
        #expect(r == p1)
    }
    
    @Test func mergeWithTwoValues() throws {
        let p1 = Pair(a: 1, b: 2)
        try resource.update(.main, with: p1)
        try resource.mergeAllForks()
        let p2 = Pair(a: 2, b: 2)
        try resource.update(.main, with: p2)
        let p3 = Pair(a: 1, b: 3)
        try resource.update(fork, with: p3)
        try #require(resource.mergeFromMain(into: fork) == .resolveConflict)
        let r = try resource.mostRecentCommit(of: fork).content.resource
        #expect(r == Pair(a: 2, b: 3)) 
    }
}
