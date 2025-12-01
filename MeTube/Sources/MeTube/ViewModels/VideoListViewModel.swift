import Foundation

#if canImport(Combine)
import Combine

/// Sync state for subscription video synchronization
public enum SyncState: Equatable {
    case idle
    case syncing
    case completed
    case failed(String)
}

/// Main view model for managing video list and filtering
@MainActor
public final class VideoListViewModel: ObservableObject {
    @Published public var videos: [Video] = []
    @Published public var channels: [Channel] = []
    @Published public var filter: VideoFilter = .defaultFilter
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var searchText: String = ""
    @Published public var syncState: SyncState = .idle
    
    private let store: VideoStoreProtocol
    private let apiClient: YouTubeAPIProtocol
    
    /// Whether the API client is configured with credentials (API key or user login)
    public var isConfigured: Bool {
        apiClient.isConfigured
    }
    
    /// Whether sync is currently in progress
    public var isSyncing: Bool {
        syncState == .syncing
    }
    
    public init(store: VideoStoreProtocol = LocalVideoStore(), apiClient: YouTubeAPIProtocol = MockYouTubeAPIClient()) {
        self.store = store
        self.apiClient = apiClient
    }
    
    /// Filtered and sorted videos based on current filter settings
    public var filteredVideos: [Video] {
        var result = videos
        
        // Apply status filters
        result = result.filter { video in
            switch video.watchStatus {
            case .unwatched: return filter.showUnwatched
            case .watched: return filter.showWatched
            case .skipped: return filter.showSkipped
            }
        }
        
        // Apply channel filter
        if let channelId = filter.selectedChannelId {
            result = result.filter { $0.channelId == channelId }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            let lowercasedSearch = searchText.lowercased()
            result = result.filter { video in
                video.title.lowercased().contains(lowercasedSearch) ||
                video.channelTitle.lowercased().contains(lowercasedSearch) ||
                video.description.lowercased().contains(lowercasedSearch)
            }
        }
        
        // Apply sort order
        switch filter.sortOrder {
        case .newestFirst:
            result.sort { $0.publishedAt > $1.publishedAt }
        case .oldestFirst:
            result.sort { $0.publishedAt < $1.publishedAt }
        }
        
        return result
    }
    
    /// Number of unwatched videos
    public var unwatchedCount: Int {
        videos.filter { $0.watchStatus == .unwatched }.count
    }
    
    /// Load videos and channels from local storage
    public func loadFromStorage() async {
        do {
            videos = try await store.loadVideos()
            channels = try await store.loadChannels()
        } catch {
            errorMessage = "Failed to load saved data: \(error.localizedDescription)"
        }
    }
    
    /// Sync subscription videos from YouTube API
    /// This is the primary method for syncing content, used for foreground sync and manual sync
    public func syncSubscriptions() async {
        guard isConfigured else {
            syncState = .failed("Not configured. Please set up API key or log in.")
            return
        }
        
        guard syncState != .syncing else { return } // Prevent multiple concurrent syncs
        
        syncState = .syncing
        errorMessage = nil
        
        do {
            // Fetch subscriptions
            channels = try await apiClient.fetchSubscriptions()
            try await store.saveChannels(channels)
            
            // Fetch videos - keep watch status from existing videos
            let existingStatusMap = Dictionary(uniqueKeysWithValues: videos.map { ($0.id, ($0.watchStatus, $0.watchedAt)) })
            
            var newVideos = try await apiClient.fetchAllSubscriptionVideos(since: nil)
            
            // Preserve watch status for existing videos
            for index in newVideos.indices {
                if let status = existingStatusMap[newVideos[index].id] {
                    newVideos[index].watchStatus = status.0
                    newVideos[index].watchedAt = status.1
                }
            }
            
            videos = newVideos
            try await store.saveVideos(videos)
            syncState = .completed
        } catch {
            errorMessage = error.localizedDescription
            syncState = .failed(error.localizedDescription)
        }
    }
    
    /// Refresh videos from YouTube API
    public func refreshFromAPI() async {
        isLoading = true
        await syncSubscriptions()
        isLoading = false
    }
    
    /// Mark a video as watched
    public func markAsWatched(_ video: Video) async {
        await updateVideoStatus(video, to: .watched)
    }
    
    /// Mark a video as skipped
    public func markAsSkipped(_ video: Video) async {
        await updateVideoStatus(video, to: .skipped)
    }
    
    /// Mark a video as unwatched
    public func markAsUnwatched(_ video: Video) async {
        await updateVideoStatus(video, to: .unwatched)
    }
    
    /// Toggle between watched and unwatched status
    public func toggleWatchStatus(_ video: Video) async {
        let newStatus: WatchStatus = video.watchStatus == .watched ? .unwatched : .watched
        await updateVideoStatus(video, to: newStatus)
    }
    
    /// Update video status and persist
    private func updateVideoStatus(_ video: Video, to status: WatchStatus) async {
        guard let index = videos.firstIndex(where: { $0.id == video.id }) else { return }
        
        videos[index].watchStatus = status
        videos[index].watchedAt = status == .watched ? Date() : nil
        
        do {
            try await store.saveVideos(videos)
        } catch {
            errorMessage = "Failed to save video status: \(error.localizedDescription)"
        }
    }
    
    /// Reset all filters to default
    public func resetFilters() {
        filter = .defaultFilter
        searchText = ""
    }
    
    /// Select a channel filter
    public func selectChannel(_ channel: Channel?) {
        filter.selectedChannelId = channel?.id
    }
    
    /// Toggle sort order
    public func toggleSortOrder() {
        filter.sortOrder = filter.sortOrder == .newestFirst ? .oldestFirst : .newestFirst
    }
    
    /// Load mock data for previews
    public func loadMockData() {
        channels = Channel.mockChannels
        videos = Video.mockVideos
    }
}
#endif
