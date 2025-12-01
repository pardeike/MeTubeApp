#if canImport(SwiftUI)
import SwiftUI

/// Main video list view showing all subscription videos
public struct VideoListView: View {
    @StateObject private var viewModel: VideoListViewModel
    @State private var showingFilter = false
    @State private var selectedVideo: Video?
    @State private var showingLoginSheet = false
    @Environment(\.scenePhase) private var scenePhase
    
    public init(viewModel: VideoListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.videos.isEmpty {
                    loadingView
                } else if viewModel.filteredVideos.isEmpty {
                    emptyStateView
                } else {
                    videoListContent
                }
            }
            .navigationTitle("MeTube")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    leadingToolbarItem
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    sortButton
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    filterButton
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "Search videos")
            .refreshable {
                await viewModel.refreshFromAPI()
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(
                    filter: $viewModel.filter,
                    channels: viewModel.channels,
                    onReset: viewModel.resetFilters
                )
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $showingLoginSheet) {
                LoginPromptView()
                    .presentationDetents([.medium])
            }
            .sheet(item: $selectedVideo) { video in
                VideoPlayerView(video: video, onStatusChange: { status in
                    Task {
                        switch status {
                        case .watched:
                            // TODO - this is now a toggle
                            await viewModel.markAsUnwatched(video)
                            await viewModel.markAsWatched(video)
                            // end todo
                        case .skipped:
                            await viewModel.markAsSkipped(video)
                        case .unwatched:
                            await viewModel.markAsUnwatched(video)
                        }
                    }
                })
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .task {
                await viewModel.loadFromStorage()
                // Load mock data if empty (for development/preview)
                if viewModel.videos.isEmpty {
                    viewModel.loadMockData()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    // Sync when app comes to foreground
                    Task {
                        await viewModel.syncSubscriptions()
                    }
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading videos...")
                .foregroundStyle(.secondary)
        }
    }
    
    private var emptyStateView: some View {
        Group {
            if #available(iOS 17.0, *) {
                ContentUnavailableView {
                    Label("No Videos", systemImage: "play.rectangle.on.rectangle")
                } description: {
                    emptyStateDescription
                } actions: {
                    emptyStateActions
                }
            } else {
                VStack(spacing: 12) {
                    Label("No Videos", systemImage: "play.rectangle.on.rectangle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    emptyStateDescription
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    emptyStateActions
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateDescription: some View {
        if viewModel.videos.isEmpty {
            Text("Pull to refresh to load videos from your subscriptions.")
        } else {
            Text("No videos match your current filters.")
        }
    }
    
    @ViewBuilder
    private var emptyStateActions: some View {
        if !viewModel.videos.isEmpty {
            Button("Reset Filters") {
                viewModel.resetFilters()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private var videoListContent: some View {
        VStack(spacing: 0) {
            // Stats bar
            statsBar
            
            // Video list
            List(viewModel.filteredVideos) { video in
                VideoRowView(
                    video: video,
                    onWatched: {
                        Task { await viewModel.markAsWatched(video) }
                    },
                    onSkipped: {
                        Task { await viewModel.markAsSkipped(video) }
                    }
                )
                .onTapGesture {
                    selectedVideo = video
                }
            }
            .listStyle(.plain)
        }
    }
    
    private var statsBar: some View {
        HStack {
            Text("\(viewModel.filteredVideos.count) videos")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            if viewModel.unwatchedCount > 0 {
                Label("\(viewModel.unwatchedCount) unwatched", systemImage: "circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    /// Leading toolbar item: shows sync indicator when configured, login button otherwise
    @ViewBuilder
    private var leadingToolbarItem: some View {
        if viewModel.isConfigured {
            syncIndicatorButton
        } else {
            loginButton
        }
    }
    
    /// Sync indicator button - shows sync status and allows manual sync
    private var syncIndicatorButton: some View {
        Button {
            Task { await viewModel.syncSubscriptions() }
        } label: {
            if viewModel.isSyncing {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                Image(systemName: syncStatusIcon)
            }
        }
        .disabled(viewModel.isSyncing)
        .accessibilityLabel(syncAccessibilityLabel)
    }
    
    private var syncStatusIcon: String {
        switch viewModel.syncState {
        case .idle:
            return "arrow.triangle.2.circlepath"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .completed:
            return "checkmark.arrow.trianglehead.counterclockwise"
        case .failed:
            return "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
        }
    }
    
    private var syncAccessibilityLabel: String {
        switch viewModel.syncState {
        case .idle:
            return "Sync subscriptions"
        case .syncing:
            return "Syncing..."
        case .completed:
            return "Sync complete. Tap to sync again."
        case .failed(let error):
            return "Sync failed: \(error). Tap to retry."
        }
    }
    
    /// Login button shown when not configured
    private var loginButton: some View {
        Button {
            showingLoginSheet = true
        } label: {
            Image(systemName: "person.crop.circle")
        }
        .accessibilityLabel("Sign in to sync subscriptions")
    }
    
    private var sortButton: some View {
        Button {
            viewModel.toggleSortOrder()
        } label: {
            Label(
                viewModel.filter.sortOrder.displayName,
                systemImage: viewModel.filter.sortOrder.systemImage
            )
        }
    }
    
    private var filterButton: some View {
        Button {
            showingFilter = true
        } label: {
            Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        }
    }
    
    private var hasActiveFilters: Bool {
        viewModel.filter != .defaultFilter || !viewModel.searchText.isEmpty
    }
}

/// Simple login prompt view explaining how to configure the app
public struct LoginPromptView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
                
                Text("Sign In Required")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("To sync your YouTube subscriptions, you need to configure the app with either:")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("YouTube API Key", systemImage: "key")
                    Label("Google Account Login", systemImage: "person.crop.circle")
                }
                .font(.body)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text("This feature is currently under development.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Setup Required")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let viewModel = VideoListViewModel()
    viewModel.loadMockData()
    return VideoListView(viewModel: viewModel)
}
#endif
