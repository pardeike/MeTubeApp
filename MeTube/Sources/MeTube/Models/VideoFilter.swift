import Foundation

/// Sort order for videos
public enum SortOrder: String, Sendable, CaseIterable, Identifiable {
    case newestFirst = "newest"
    case oldestFirst = "oldest"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .newestFirst: return "Newest First"
        case .oldestFirst: return "Oldest First"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .newestFirst: return "arrow.down"
        case .oldestFirst: return "arrow.up"
        }
    }
}

/// Filter options for the video list
public struct VideoFilter: Sendable, Equatable {
    public var showWatched: Bool
    public var showSkipped: Bool
    public var showUnwatched: Bool
    public var selectedChannelId: String?
    public var sortOrder: SortOrder
    
    public static let defaultFilter = VideoFilter(
        showWatched: false,
        showSkipped: false,
        showUnwatched: true,
        selectedChannelId: nil,
        sortOrder: .newestFirst
    )
    
    public init(
        showWatched: Bool = false,
        showSkipped: Bool = false,
        showUnwatched: Bool = true,
        selectedChannelId: String? = nil,
        sortOrder: SortOrder = .newestFirst
    ) {
        self.showWatched = showWatched
        self.showSkipped = showSkipped
        self.showUnwatched = showUnwatched
        self.selectedChannelId = selectedChannelId
        self.sortOrder = sortOrder
    }
    
    /// Returns true if no status filters are active (show all)
    public var showsAllStatuses: Bool {
        showWatched && showSkipped && showUnwatched
    }
    
    /// Returns true if at least one status filter is active
    public var hasActiveStatusFilter: Bool {
        showWatched || showSkipped || showUnwatched
    }
}
