import Foundation

/// A wrapper to hold the resource. This allows for the resource to be
/// absent in a fork, similar to using `nil`.
public enum CommitContent<ResourceType: Resource> {
    /// The content is not present. Perhaps it has not been added yet,
    /// or it may have been removed.
    case none
    
    /// The content contains a value of the resource.
    case resource(ResourceType)
}

/// A commit comprises of content, which is usually a value of the stored resource,
/// together with a `Version`.
public struct Commit<ResourceType: Resource>: Hashable, Equatable {
    /// The content stored in the commit, usually a copy of the resource.
    public var content: CommitContent<ResourceType>
    
    /// The version when the copy of the resource was committed.
    public var version: Version
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(version)
    }
    
    public static func == (lhs: Commit<ResourceType>, rhs: Commit<ResourceType>) -> Bool {
        lhs.version == rhs.version
    }
}

extension CommitContent: Codable where ResourceType: Codable {}
extension CommitContent: Equatable where ResourceType: Equatable {}
extension Commit: Codable where ResourceType: Codable {}
