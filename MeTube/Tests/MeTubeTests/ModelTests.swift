import XCTest
@testable import MeTube

final class VideoTests: XCTestCase {
    
    func testVideoInitialization() {
        let video = Video(
            id: "test123",
            channelId: "channel1",
            channelTitle: "Test Channel",
            title: "Test Video",
            description: "A test video description",
            publishedAt: Date(),
            duration: 3661 // 1 hour, 1 minute, 1 second
        )
        
        XCTAssertEqual(video.id, "test123")
        XCTAssertEqual(video.channelId, "channel1")
        XCTAssertEqual(video.channelTitle, "Test Channel")
        XCTAssertEqual(video.title, "Test Video")
        XCTAssertEqual(video.watchStatus, .unwatched)
        XCTAssertNil(video.watchedAt)
    }
    
    func testFormattedDuration_UnderOneHour() {
        let video = Video(
            id: "test",
            channelId: "channel",
            channelTitle: "Channel",
            title: "Title",
            description: "",
            publishedAt: Date(),
            duration: 754 // 12 minutes, 34 seconds
        )
        
        XCTAssertEqual(video.formattedDuration, "12:34")
    }
    
    func testFormattedDuration_OverOneHour() {
        let video = Video(
            id: "test",
            channelId: "channel",
            channelTitle: "Channel",
            title: "Title",
            description: "",
            publishedAt: Date(),
            duration: 5025 // 1 hour, 23 minutes, 45 seconds
        )
        
        XCTAssertEqual(video.formattedDuration, "1:23:45")
    }
    
    func testFormattedDuration_ZeroSeconds() {
        let video = Video(
            id: "test",
            channelId: "channel",
            channelTitle: "Channel",
            title: "Title",
            description: "",
            publishedAt: Date(),
            duration: 0
        )
        
        XCTAssertEqual(video.formattedDuration, "0:00")
    }
    
    func testWatchStatusUpdate() {
        var video = Video(
            id: "test",
            channelId: "channel",
            channelTitle: "Channel",
            title: "Title",
            description: "",
            publishedAt: Date()
        )
        
        XCTAssertEqual(video.watchStatus, .unwatched)
        
        video.watchStatus = .watched
        video.watchedAt = Date()
        
        XCTAssertEqual(video.watchStatus, .watched)
        XCTAssertNotNil(video.watchedAt)
    }
}

final class WatchStatusTests: XCTestCase {
    
    func testWatchStatusDisplayNames() {
        XCTAssertEqual(WatchStatus.unwatched.displayName, "Unwatched")
        XCTAssertEqual(WatchStatus.watched.displayName, "Watched")
        XCTAssertEqual(WatchStatus.skipped.displayName, "Skipped")
    }
    
    func testWatchStatusSystemImages() {
        XCTAssertEqual(WatchStatus.unwatched.systemImage, "circle")
        XCTAssertEqual(WatchStatus.watched.systemImage, "checkmark.circle.fill")
        XCTAssertEqual(WatchStatus.skipped.systemImage, "forward.fill")
    }
}

final class ChannelTests: XCTestCase {
    
    func testChannelInitialization() {
        let channel = Channel(
            id: "channel123",
            title: "Test Channel",
            thumbnailURL: URL(string: "https://example.com/thumb.jpg")
        )
        
        XCTAssertEqual(channel.id, "channel123")
        XCTAssertEqual(channel.title, "Test Channel")
        XCTAssertNotNil(channel.thumbnailURL)
    }
    
    func testChannelEquality() {
        let timestamp = Date()
        let channel1 = Channel(id: "1", title: "Channel 1", subscribedAt: timestamp)
        let channel2 = Channel(id: "1", title: "Channel 1", subscribedAt: timestamp)
        let channel3 = Channel(id: "2", title: "Channel 2", subscribedAt: timestamp)
        
        XCTAssertEqual(channel1, channel2)
        XCTAssertNotEqual(channel1, channel3)
    }
}
