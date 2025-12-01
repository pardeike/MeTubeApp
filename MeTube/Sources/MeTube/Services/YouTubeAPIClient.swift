import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Protocol for YouTube API operations
public protocol YouTubeAPIProtocol: Sendable {
    /// Whether the API client is configured with valid credentials (API key or user login)
    var isConfigured: Bool { get }
    
    func fetchSubscriptions() async throws -> [Channel]
    func fetchVideos(forChannel channelId: String, since date: Date?) async throws -> [Video]
    func fetchAllSubscriptionVideos(since date: Date?) async throws -> [Video]
}

/// Errors that can occur during YouTube API operations
public enum YouTubeAPIError: Error, LocalizedError {
    case notAuthenticated
    case networkError(underlying: Error)
    case invalidResponse
    case quotaExceeded
    case channelNotFound
    
    public var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with YouTube. Please sign in."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from YouTube API."
        case .quotaExceeded:
            return "YouTube API quota exceeded. Please try again later."
        case .channelNotFound:
            return "Channel not found."
        }
    }
}

#if canImport(Darwin)
/// YouTube API client implementation
/// Note: This is a stub implementation. Actual implementation requires YouTube Data API v3 credentials.
public final class YouTubeAPIClient: YouTubeAPIProtocol, @unchecked Sendable {
    private let apiKey: String?
    private let session: URLSession
    
    public init(apiKey: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.session = session
    }
    
    /// Returns true if an API key is configured
    public var isConfigured: Bool {
        guard let key = apiKey else { return false }
        return !key.isEmpty
    }
    
    public func fetchSubscriptions() async throws -> [Channel] {
        // Stub implementation - returns mock data for development
        // Real implementation would use YouTube Data API v3
        return []
    }
    
    public func fetchVideos(forChannel channelId: String, since date: Date?) async throws -> [Video] {
        // Stub implementation - returns mock data for development
        // Real implementation would use YouTube Data API v3
        return []
    }
    
    public func fetchAllSubscriptionVideos(since date: Date?) async throws -> [Video] {
        let channels = try await fetchSubscriptions()
        var allVideos: [Video] = []
        
        for channel in channels {
            let videos = try await fetchVideos(forChannel: channel.id, since: date)
            allVideos.append(contentsOf: videos)
        }
        
        return allVideos
    }
}
#endif

/// Mock YouTube API client for testing and preview
public final class MockYouTubeAPIClient: YouTubeAPIProtocol, @unchecked Sendable {
    private let _isConfigured: Bool
    
    /// Creates a mock API client
    /// - Parameter isConfigured: Whether the client should report as configured.
    ///   Defaults to `false` so the app shows login button in production.
    ///   Set to `true` in tests/previews to simulate a configured state.
    public init(isConfigured: Bool = false) {
        self._isConfigured = isConfigured
    }
    
    /// Mock client reports as unconfigured by default (shows login button)
    public var isConfigured: Bool {
        _isConfigured
    }
    
    public func fetchSubscriptions() async throws -> [Channel] {
        return Channel.mockChannels
    }
    
    public func fetchVideos(forChannel channelId: String, since date: Date?) async throws -> [Video] {
        return Video.mockVideos.filter { $0.channelId == channelId }
    }
    
    public func fetchAllSubscriptionVideos(since date: Date?) async throws -> [Video] {
        return Video.mockVideos
    }
}

// MARK: - Mock Data

extension Channel {
    public static let mockChannels: [Channel] = [
        Channel(
            id: "UC_x5XG1OV2P6uZZ5FSM9Ttw",
            title: "Google Developers",
            thumbnailURL: URL(string: "https://yt3.ggpht.com/example1"),
            subscribedAt: Date().addingTimeInterval(-86400 * 365)
        ),
        Channel(
            id: "UCVHFbqXqoYvEWM1Ddxl0QDg",
            title: "Apple",
            thumbnailURL: URL(string: "https://yt3.ggpht.com/example2"),
            subscribedAt: Date().addingTimeInterval(-86400 * 180)
        ),
        Channel(
            id: "UCXuqSBlHAE6Xw-yeJA0Tunw",
            title: "Linus Tech Tips",
            thumbnailURL: URL(string: "https://yt3.ggpht.com/example3"),
            subscribedAt: Date().addingTimeInterval(-86400 * 90)
        )
    ]
}

extension Video {
    public static let mockVideos: [Video] = [
        Video(
            id: "video1",
            channelId: "UC_x5XG1OV2P6uZZ5FSM9Ttw",
            channelTitle: "Google Developers",
            title: "What's new in Swift 6",
            description: "Learn about the latest features in Swift 6, including typed throws and improved concurrency.",
            thumbnailURL: URL(string: "https://i.ytimg.com/vi/example1/maxresdefault.jpg"),
            publishedAt: Date().addingTimeInterval(-3600),
            duration: 1234,
            watchStatus: .unwatched
        ),
        Video(
            id: "video2",
            channelId: "UCVHFbqXqoYvEWM1Ddxl0QDg",
            channelTitle: "Apple",
            title: "Introducing iPhone 16",
            description: "The all-new iPhone 16 with amazing features.",
            thumbnailURL: URL(string: "https://i.ytimg.com/vi/example2/maxresdefault.jpg"),
            publishedAt: Date().addingTimeInterval(-7200),
            duration: 567,
            watchStatus: .watched,
            watchedAt: Date().addingTimeInterval(-3600)
        ),
        Video(
            id: "video3",
            channelId: "UCXuqSBlHAE6Xw-yeJA0Tunw",
            channelTitle: "Linus Tech Tips",
            title: "Building the Ultimate Gaming PC",
            description: "We build the most powerful gaming PC ever.",
            thumbnailURL: URL(string: "https://i.ytimg.com/vi/example3/maxresdefault.jpg"),
            publishedAt: Date().addingTimeInterval(-86400),
            duration: 987,
            watchStatus: .skipped
        ),
        Video(
            id: "video4",
            channelId: "UC_x5XG1OV2P6uZZ5FSM9Ttw",
            channelTitle: "Google Developers",
            title: "Building Modern Web Apps",
            description: "A comprehensive guide to modern web development.",
            thumbnailURL: URL(string: "https://i.ytimg.com/vi/example4/maxresdefault.jpg"),
            publishedAt: Date().addingTimeInterval(-172800),
            duration: 2345,
            watchStatus: .unwatched
        ),
        Video(
            id: "video5",
            channelId: "UCVHFbqXqoYvEWM1Ddxl0QDg",
            channelTitle: "Apple",
            title: "WWDC 2025 Keynote",
            description: "All the announcements from WWDC 2025.",
            thumbnailURL: URL(string: "https://i.ytimg.com/vi/example5/maxresdefault.jpg"),
            publishedAt: Date().addingTimeInterval(-259200),
            duration: 7890,
            watchStatus: .unwatched
        )
    ]
}
