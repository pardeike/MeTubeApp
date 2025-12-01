import Foundation

/// Represents the watch status of a video
public enum WatchStatus: String, Sendable, Codable, Equatable, CaseIterable {
    case unwatched
    case watched
    case skipped
    
    public var displayName: String {
        switch self {
        case .unwatched: return "Unwatched"
        case .watched: return "Watched"
        case .skipped: return "Skipped"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .unwatched: return "circle"
        case .watched: return "checkmark.circle.fill"
        case .skipped: return "forward.fill"
        }
    }
}
