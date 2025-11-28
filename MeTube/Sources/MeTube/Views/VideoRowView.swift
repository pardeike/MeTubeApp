#if canImport(SwiftUI)
import SwiftUI

/// Row view for displaying a single video in the list
public struct VideoRowView: View {
    let video: Video
    let onWatched: () -> Void
    let onSkipped: () -> Void
    
    public init(video: Video, onWatched: @escaping () -> Void, onSkipped: @escaping () -> Void) {
        self.video = video
        self.onWatched = onWatched
        self.onSkipped = onSkipped
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Thumbnail
            thumbnailView
            
            // Video info
            VStack(alignment: .leading, spacing: 4) {
                // Title
                Text(video.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(video.watchStatus == .watched ? .secondary : .primary)
                
                // Channel name
                Text(video.channelTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // Metadata row
                HStack(spacing: 8) {
                    // Published time
                    Text(video.relativePublishedTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    // Duration
                    Text(video.formattedDuration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Watch status indicator
                    Image(systemName: video.watchStatus.systemImage)
                        .foregroundStyle(statusColor)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            let watchedLabel = video.watchStatus != .watched ? "Watched" : "Unwatch"
            let watchTint: Color = video.watchStatus != .watched ? .green : .gray
            Button {
                onWatched()
            } label: {
                Label(watchedLabel, systemImage: "checkmark.circle.fill")
            }
            .tint(watchTint)
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                onSkipped()
            } label: {
                Label("Skip", systemImage: "forward.fill")
            }
            .tint(.orange)
        }
    }
    
    @ViewBuilder
    private var thumbnailView: some View {
        ZStack(alignment: .bottomTrailing) {
            // Thumbnail image placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 160, height: 90)
                .overlay {
                    if let url = video.thumbnailURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "play.rectangle.fill")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 160, height: 90)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "play.rectangle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                }
            
            // Duration badge
            Text(video.formattedDuration)
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.black.opacity(0.7))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(4)
        }
    }
    
    private var statusColor: Color {
        switch video.watchStatus {
        case .unwatched: return .primary
        case .watched: return .green
        case .skipped: return .orange
        }
    }
}

#Preview {
    List {
        VideoRowView(
            video: Video.mockVideos[0],
            onWatched: {},
            onSkipped: {}
        )
        VideoRowView(
            video: Video.mockVideos[1],
            onWatched: {},
            onSkipped: {}
        )
        VideoRowView(
            video: Video.mockVideos[2],
            onWatched: {},
            onSkipped: {}
        )
    }
    .listStyle(.plain)
}
#endif
