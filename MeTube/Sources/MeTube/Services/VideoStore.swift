import Foundation

/// Protocol for persisting video and channel data
public protocol VideoStoreProtocol: Sendable {
    func loadVideos() async throws -> [Video]
    func saveVideos(_ videos: [Video]) async throws
    func loadChannels() async throws -> [Channel]
    func saveChannels(_ channels: [Channel]) async throws
}

/// Local storage implementation using UserDefaults and JSON encoding
public final class LocalVideoStore: VideoStoreProtocol, @unchecked Sendable {
    private let videosKey = "com.metube.videos"
    private let channelsKey = "com.metube.channels"
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public func loadVideos() async throws -> [Video] {
        guard let data = defaults.data(forKey: videosKey) else {
            return []
        }
        return try decoder.decode([Video].self, from: data)
    }
    
    public func saveVideos(_ videos: [Video]) async throws {
        let data = try encoder.encode(videos)
        defaults.set(data, forKey: videosKey)
    }
    
    public func loadChannels() async throws -> [Channel] {
        guard let data = defaults.data(forKey: channelsKey) else {
            return []
        }
        return try decoder.decode([Channel].self, from: data)
    }
    
    public func saveChannels(_ channels: [Channel]) async throws {
        let data = try encoder.encode(channels)
        defaults.set(data, forKey: channelsKey)
    }
}
