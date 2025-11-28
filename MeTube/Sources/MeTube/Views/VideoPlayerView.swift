#if canImport(SwiftUI)
import SwiftUI

/// Video player view for watching a video
public struct VideoPlayerView: View {
    let video: Video
    let onStatusChange: (WatchStatus) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var currentStatus: WatchStatus
    
    public init(video: Video, onStatusChange: @escaping (WatchStatus) -> Void) {
        self.video = video
        self.onStatusChange = onStatusChange
        self._currentStatus = State(initialValue: video.watchStatus)
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Video player placeholder
                    videoPlayerPlaceholder
                    
                    // Video info
                    VStack(alignment: .leading, spacing: 12) {
                        // Title
                        Text(video.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // Metadata
                        HStack {
                            Text(video.channelTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text(video.relativePublishedTime)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Divider()
                        
                        // Status controls
                        statusControls
                        
                        Divider()
                        
                        // Description
                        Text("Description")
                            .font(.headline)
                        
                        Text(video.description)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
            }
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
    
    private var videoPlayerPlaceholder: some View {
        ZStack {
            // Thumbnail background
            if let url = video.thumbnailURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fit)
                } placeholder: {
                    playerPlaceholderBackground
                }
            } else {
                playerPlaceholderBackground
            }
            
            // Play button overlay
            Button {
                // In a real app, this would start playback
                // For now, mark as watched
                updateStatus(.watched)
            } label: {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
            }
            
            // YouTube link hint
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Link(destination: youtubeURL) {
                        Label("Open in YouTube", systemImage: "arrow.up.right.square")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                    }
                    .padding(8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(16/9, contentMode: .fit)
        .background(Color.black)
    }
    
    private var playerPlaceholderBackground: some View {
        Rectangle()
            .fill(Color.black)
            .aspectRatio(16/9, contentMode: .fit)
            .overlay {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.gray)
            }
    }
    
    private var statusControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mark as")
                .font(.headline)
            
            HStack(spacing: 12) {
                statusButton(.watched, label: "Watched", icon: "checkmark.circle.fill", color: .green)
                statusButton(.skipped, label: "Skipped", icon: "forward.fill", color: .orange)
                statusButton(.unwatched, label: "Unwatched", icon: "circle", color: .gray)
            }
        }
    }
    
    private func statusButton(_ status: WatchStatus, label: String, icon: String, color: Color) -> some View {
        Button {
            updateStatus(status)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(currentStatus == status ? color.opacity(0.2) : Color(.secondarySystemBackground))
            .foregroundStyle(currentStatus == status ? color : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(currentStatus == status ? color : .clear, lineWidth: 2)
            }
        }
    }
    
    private func updateStatus(_ status: WatchStatus) {
        currentStatus = status
        onStatusChange(status)
    }
    
    private var youtubeURL: URL {
        URL(string: "https://www.youtube.com/watch?v=\(video.id)")!
    }
}

#Preview {
    VideoPlayerView(
        video: Video.mockVideos[0],
        onStatusChange: { _ in }
    )
}
#endif
