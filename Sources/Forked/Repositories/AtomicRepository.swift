import Foundation

class AtomicRepository<ResourceType: Resource>: Repository {
    private var forkToResource: [Fork:[Commit<ResourceType>]] = [:]
    
    var forks: [Fork] {
        Array(forkToResource.keys)
    }
    
    func create(_ fork: Fork) throws {
        guard forkToResource[fork] == nil else { 
            throw Error.attemptToCreateExistingFork(fork)
        }
        forkToResource[fork] = []
    }
    
    func delete(_ fork: Fork) throws {
        guard forkToResource[fork] != nil else {
            throw Error.attemptToAccessNonExistentFork(fork)
        }
        forkToResource[fork] = nil
    }
    
    func versions(storedIn fork: Fork) throws -> Set<Version> {
        guard let commits = forkToResource[fork] else {
            throw Error.attemptToAccessNonExistentFork(fork)
        }
        return Set(commits.map { $0.version })
    }
    
    func removeCommit(at version: Version, from fork: Fork) throws {
        guard forkToResource[fork]?.first(where: { $0.version == version }) != nil else {
            throw Error.attemptToAccessNonExistentVersion(version, fork)
        }
        forkToResource[fork]!.removeAll(where: { $0.version == version })
    }
    
    func content(of fork: Fork, at version: Version) throws -> CommitContent<ResourceType> {
        guard let commit = forkToResource[fork]?.first(where: { $0.version == version }) else {
            throw Error.attemptToAccessNonExistentVersion(version, fork)
        }
        return commit.content
    }
    
    func store(_ commit: Commit<ResourceType>, in fork: Fork) throws {
        guard forkToResource[fork] != nil else {
            throw Error.attemptToAccessNonExistentFork(fork)
        }
        guard !forkToResource[fork]!.contains(where: { $0.version == commit.version }) else {
            throw Error.attemptToReplaceExistingVersion(commit.version, fork)
        }
        forkToResource[fork]!.append(commit)
    }
    
}