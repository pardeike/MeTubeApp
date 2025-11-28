#if canImport(SwiftUI)
import SwiftUI

/// Main video list view showing all subscription videos
public struct VideoListView: View {
    @StateObject private var viewModel: VideoListViewModel
    @State private var showingFilter = false
    @State private var selectedVideo: Video?
    
    public init(viewModel: VideoListViewModel = VideoListViewModel()) {
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
                    sortButton
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    filterButton
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    refreshButton
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
            .sheet(item: $selectedVideo) { video in
                VideoPlayerView(video: video, onStatusChange: { status in
                    Task {
                        switch status {
                        case .watched:
                            await viewModel.markAsWatched(video)
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
        ContentUnavailableView {
            Label("No Videos", systemImage: "play.rectangle.on.rectangle")
        } description: {
            if viewModel.videos.isEmpty {
                Text("Pull to refresh to load videos from your subscriptions.")
            } else {
                Text("No videos match your current filters.")
            }
        } actions: {
            if !viewModel.videos.isEmpty {
                Button("Reset Filters") {
                    viewModel.resetFilters()
                }
                .buttonStyle(.bordered)
            }
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
    
    private var refreshButton: some View {
        Button {
            Task { await viewModel.refreshFromAPI() }
        } label: {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Image(systemName: "arrow.clockwise")
            }
        }
        .disabled(viewModel.isLoading)
    }
    
    private var hasActiveFilters: Bool {
        viewModel.filter != .defaultFilter || !viewModel.searchText.isEmpty
    }
}

#Preview {
    let viewModel = VideoListViewModel()
    viewModel.loadMockData()
    return VideoListView(viewModel: viewModel)
}
#endif
