# MeTubeApp

A YouTube app that shows you only subscribed channels - a focus-oriented alternative to the main YouTube app.

## Features

MeTube is designed as a **focus app** (similar to Opal or Focus Friend) that helps you consume YouTube content mindfully:

### ✅ No Algorithmic Content
- **No recommendations** - Only shows videos from channels you're subscribed to
- **No suggested videos** - No distracting "up next" or related videos
- **No trending** - Focus only on content you've chosen to follow

### ✅ Temporal Ordering
- View videos sorted by **newest first** or **oldest first**
- Understand your subscription backlog at a glance
- Process videos in the order they were published

### ✅ Watch Status Tracking
- Mark videos as **Watched** ✓
- Mark videos as **Skipped** → (for content you want to skip intentionally)
- Clear indication of **Unwatched** content

### ✅ Powerful Filtering
- Filter by **watch status** (unwatched, watched, skipped)
- Filter by **specific channel**
- **Search** across video titles, descriptions, and channel names
- See counts of unwatched videos

## Project Structure

```
MeTube/
├── Package.swift                 # Swift Package Manager configuration
├── Sources/MeTube/
│   ├── Models/
│   │   ├── Channel.swift         # YouTube channel model
│   │   ├── Video.swift           # Video model with watch status
│   │   ├── VideoFilter.swift     # Filter and sort options
│   │   └── WatchStatus.swift     # Watch status enum
│   ├── Views/
│   │   ├── FilterView.swift      # Filter controls UI
│   │   ├── VideoListView.swift   # Main video list
│   │   ├── VideoPlayerView.swift # Video player/details
│   │   └── VideoRowView.swift    # Individual video row
│   ├── ViewModels/
│   │   └── VideoListViewModel.swift  # Business logic
│   └── Services/
│       ├── VideoStore.swift      # Local persistence
│       └── YouTubeAPIClient.swift # YouTube API integration
└── Tests/MeTubeTests/
    ├── ModelTests.swift
    ├── VideoFilterTests.swift
    └── VideoListViewModelTests.swift
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Building

Open the project in Xcode or build from command line on macOS:

```bash
cd MeTube
swift build
```

Run tests:

```bash
swift test
```

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture:

- **Models**: Pure data structures (`Video`, `Channel`, `WatchStatus`, `VideoFilter`)
- **Views**: SwiftUI views for the UI (`VideoListView`, `VideoRowView`, etc.)
- **ViewModels**: Business logic and state management (`VideoListViewModel`)
- **Services**: Data persistence and API integration (`VideoStore`, `YouTubeAPIClient`)

## YouTube API Integration

The app includes a stub `YouTubeAPIClient` that needs to be configured with YouTube Data API v3 credentials for production use. The `MockYouTubeAPIClient` provides sample data for development and testing.

To integrate with the real YouTube API:
1. Obtain YouTube Data API v3 credentials from Google Cloud Console
2. Configure OAuth 2.0 for user authentication
3. Implement the `fetchSubscriptions()` and `fetchVideos()` methods in `YouTubeAPIClient`

## Usage

1. **Browse Videos**: The main screen shows all unwatched videos from your subscriptions
2. **Filter Videos**: Tap the filter icon to show/hide watched or skipped videos
3. **Change Sort Order**: Tap the sort button to toggle between newest/oldest first
4. **Search**: Use the search bar to find specific videos
5. **Mark as Watched**: Swipe right on a video to mark it as watched
6. **Mark as Skipped**: Swipe left on a video to skip it
7. **View Details**: Tap a video to see details and manually change its status

## License

MIT License - See [LICENSE](LICENSE) for details.

