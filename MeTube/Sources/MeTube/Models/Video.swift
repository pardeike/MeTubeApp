import Foundation

/// Represents a YouTube video from a subscribed channel
public struct Video: Identifiable, Codable, Equatable {
    public let id: String
    public let channelId: String
    public let channelTitle: String
    public let title: String
    public let description: String
    public let thumbnailURL: URL?
    public let publishedAt: Date
    public let duration: TimeInterval
    public var watchStatus: WatchStatus
    public var watchedAt: Date?
    
    public init(
        id: String,
        channelId: String,
        channelTitle: String,
        title: String,
        description: String,
        thumbnailURL: URL? = nil,
        publishedAt: Date,
        duration: TimeInterval = 0,
        watchStatus: WatchStatus = .unwatched,
        watchedAt: Date? = nil
    ) {
        self.id = id
        self.channelId = channelId
        self.channelTitle = channelTitle
        self.title = title
        self.description = description
        self.thumbnailURL = thumbnailURL
        self.publishedAt = publishedAt
        self.duration = duration
        self.watchStatus = watchStatus
        self.watchedAt = watchedAt
    }
    
    /// Formatted duration string (e.g., "12:34" or "1:23:45")
    public var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    /// Relative time since published (e.g., "2 hours ago")
    public var relativePublishedTime: String {
        #if canImport(Darwin)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
        #else
        // Fallback for Linux - simple time ago calculation
        let interval = Date().timeIntervalSince(publishedAt)
        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        
        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "just now"
        }
        #endif
    }
}
