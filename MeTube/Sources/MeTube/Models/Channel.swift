import Foundation

/// Represents a YouTube channel the user is subscribed to
public struct Channel: Sendable, Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let thumbnailURL: URL?
    public let subscribedAt: Date
    
    public init(id: String, title: String, thumbnailURL: URL? = nil, subscribedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.thumbnailURL = thumbnailURL
        self.subscribedAt = subscribedAt
    }
}
