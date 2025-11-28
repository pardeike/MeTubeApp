import XCTest
@testable import MeTube

#if canImport(Combine)
@MainActor
final class VideoListViewModelTests: XCTestCase {
    
    func testInitialState() async {
        let viewModel = VideoListViewModel()
        
        XCTAssertTrue(viewModel.videos.isEmpty)
        XCTAssertTrue(viewModel.channels.isEmpty)
        XCTAssertEqual(viewModel.filter, .defaultFilter)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.searchText.isEmpty)
    }
    
    func testLoadMockData() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        XCTAssertFalse(viewModel.videos.isEmpty)
        XCTAssertFalse(viewModel.channels.isEmpty)
        XCTAssertEqual(viewModel.videos.count, Video.mockVideos.count)
        XCTAssertEqual(viewModel.channels.count, Channel.mockChannels.count)
    }
    
    func testFilteredVideos_UnwatchedOnly() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        // Default filter shows only unwatched
        let unwatchedVideos = viewModel.filteredVideos
        
        XCTAssertTrue(unwatchedVideos.allSatisfy { $0.watchStatus == .unwatched })
    }
    
    func testFilteredVideos_AllStatuses() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        viewModel.filter.showWatched = true
        viewModel.filter.showSkipped = true
        viewModel.filter.showUnwatched = true
        
        XCTAssertEqual(viewModel.filteredVideos.count, viewModel.videos.count)
    }
    
    func testFilteredVideos_ByChannel() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        // Show all statuses
        viewModel.filter.showWatched = true
        viewModel.filter.showSkipped = true
        viewModel.filter.showUnwatched = true
        
        guard let firstChannel = viewModel.channels.first else {
            XCTFail("No channels loaded")
            return
        }
        
        viewModel.filter.selectedChannelId = firstChannel.id
        
        let filteredVideos = viewModel.filteredVideos
        XCTAssertTrue(filteredVideos.allSatisfy { $0.channelId == firstChannel.id })
    }
    
    func testFilteredVideos_SortOrder() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        // Show all statuses
        viewModel.filter.showWatched = true
        viewModel.filter.showSkipped = true
        viewModel.filter.showUnwatched = true
        
        // Test newest first
        viewModel.filter.sortOrder = .newestFirst
        let newestFirst = viewModel.filteredVideos
        for i in 0..<(newestFirst.count - 1) {
            XCTAssertGreaterThanOrEqual(newestFirst[i].publishedAt, newestFirst[i + 1].publishedAt)
        }
        
        // Test oldest first
        viewModel.filter.sortOrder = .oldestFirst
        let oldestFirst = viewModel.filteredVideos
        for i in 0..<(oldestFirst.count - 1) {
            XCTAssertLessThanOrEqual(oldestFirst[i].publishedAt, oldestFirst[i + 1].publishedAt)
        }
    }
    
    func testSearchFilter() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        // Show all statuses
        viewModel.filter.showWatched = true
        viewModel.filter.showSkipped = true
        viewModel.filter.showUnwatched = true
        
        viewModel.searchText = "Swift"
        
        let filtered = viewModel.filteredVideos
        XCTAssertTrue(filtered.allSatisfy { video in
            video.title.lowercased().contains("swift") ||
            video.channelTitle.lowercased().contains("swift") ||
            video.description.lowercased().contains("swift")
        })
    }
    
    func testUnwatchedCount() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        let expectedUnwatched = viewModel.videos.filter { $0.watchStatus == .unwatched }.count
        XCTAssertEqual(viewModel.unwatchedCount, expectedUnwatched)
    }
    
    func testMarkAsWatched() async {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        guard let unwatchedVideo = viewModel.videos.first(where: { $0.watchStatus == .unwatched }) else {
            XCTFail("No unwatched video found")
            return
        }
        
        await viewModel.markAsWatched(unwatchedVideo)
        
        let updatedVideo = viewModel.videos.first(where: { $0.id == unwatchedVideo.id })
        XCTAssertEqual(updatedVideo?.watchStatus, .watched)
        XCTAssertNotNil(updatedVideo?.watchedAt)
    }
    
    func testMarkAsSkipped() async {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        guard let unwatchedVideo = viewModel.videos.first(where: { $0.watchStatus == .unwatched }) else {
            XCTFail("No unwatched video found")
            return
        }
        
        await viewModel.markAsSkipped(unwatchedVideo)
        
        let updatedVideo = viewModel.videos.first(where: { $0.id == unwatchedVideo.id })
        XCTAssertEqual(updatedVideo?.watchStatus, .skipped)
    }
    
    func testMarkAsUnwatched() async {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        guard let watchedVideo = viewModel.videos.first(where: { $0.watchStatus == .watched }) else {
            XCTFail("No watched video found")
            return
        }
        
        await viewModel.markAsUnwatched(watchedVideo)
        
        let updatedVideo = viewModel.videos.first(where: { $0.id == watchedVideo.id })
        XCTAssertEqual(updatedVideo?.watchStatus, .unwatched)
        XCTAssertNil(updatedVideo?.watchedAt)
    }
    
    func testToggleWatchStatus() async {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        guard let unwatchedVideo = viewModel.videos.first(where: { $0.watchStatus == .unwatched }) else {
            XCTFail("No unwatched video found")
            return
        }
        
        // Toggle to watched
        await viewModel.toggleWatchStatus(unwatchedVideo)
        var updatedVideo = viewModel.videos.first(where: { $0.id == unwatchedVideo.id })!
        XCTAssertEqual(updatedVideo.watchStatus, .watched)
        
        // Toggle back to unwatched
        await viewModel.toggleWatchStatus(updatedVideo)
        updatedVideo = viewModel.videos.first(where: { $0.id == unwatchedVideo.id })!
        XCTAssertEqual(updatedVideo.watchStatus, .unwatched)
    }
    
    func testResetFilters() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        // Modify filters
        viewModel.filter.showWatched = true
        viewModel.filter.showSkipped = true
        viewModel.filter.selectedChannelId = "channel1"
        viewModel.searchText = "test"
        
        // Reset
        viewModel.resetFilters()
        
        XCTAssertEqual(viewModel.filter, .defaultFilter)
        XCTAssertTrue(viewModel.searchText.isEmpty)
    }
    
    func testSelectChannel() {
        let viewModel = VideoListViewModel()
        viewModel.loadMockData()
        
        guard let channel = viewModel.channels.first else {
            XCTFail("No channels loaded")
            return
        }
        
        viewModel.selectChannel(channel)
        XCTAssertEqual(viewModel.filter.selectedChannelId, channel.id)
        
        viewModel.selectChannel(nil)
        XCTAssertNil(viewModel.filter.selectedChannelId)
    }
    
    func testToggleSortOrder() {
        let viewModel = VideoListViewModel()
        
        XCTAssertEqual(viewModel.filter.sortOrder, .newestFirst)
        
        viewModel.toggleSortOrder()
        XCTAssertEqual(viewModel.filter.sortOrder, .oldestFirst)
        
        viewModel.toggleSortOrder()
        XCTAssertEqual(viewModel.filter.sortOrder, .newestFirst)
    }
}
#endif
