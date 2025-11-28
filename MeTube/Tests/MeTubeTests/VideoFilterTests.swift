import XCTest
@testable import MeTube

final class VideoFilterTests: XCTestCase {
    
    func testDefaultFilter() {
        let filter = VideoFilter.defaultFilter
        
        XCTAssertFalse(filter.showWatched)
        XCTAssertFalse(filter.showSkipped)
        XCTAssertTrue(filter.showUnwatched)
        XCTAssertNil(filter.selectedChannelId)
        XCTAssertEqual(filter.sortOrder, .newestFirst)
    }
    
    func testShowsAllStatuses() {
        let allFilter = VideoFilter(
            showWatched: true,
            showSkipped: true,
            showUnwatched: true
        )
        XCTAssertTrue(allFilter.showsAllStatuses)
        
        let partialFilter = VideoFilter(
            showWatched: true,
            showSkipped: false,
            showUnwatched: true
        )
        XCTAssertFalse(partialFilter.showsAllStatuses)
    }
    
    func testHasActiveStatusFilter() {
        let activeFilter = VideoFilter(
            showWatched: false,
            showSkipped: false,
            showUnwatched: true
        )
        XCTAssertTrue(activeFilter.hasActiveStatusFilter)
        
        let noFilter = VideoFilter(
            showWatched: false,
            showSkipped: false,
            showUnwatched: false
        )
        XCTAssertFalse(noFilter.hasActiveStatusFilter)
    }
    
    func testFilterEquality() {
        let filter1 = VideoFilter.defaultFilter
        let filter2 = VideoFilter.defaultFilter
        
        XCTAssertEqual(filter1, filter2)
        
        var filter3 = VideoFilter.defaultFilter
        filter3.showWatched = true
        
        XCTAssertNotEqual(filter1, filter3)
    }
}

final class SortOrderTests: XCTestCase {
    
    func testSortOrderDisplayNames() {
        XCTAssertEqual(SortOrder.newestFirst.displayName, "Newest First")
        XCTAssertEqual(SortOrder.oldestFirst.displayName, "Oldest First")
    }
    
    func testSortOrderSystemImages() {
        XCTAssertEqual(SortOrder.newestFirst.systemImage, "arrow.down")
        XCTAssertEqual(SortOrder.oldestFirst.systemImage, "arrow.up")
    }
    
    func testSortOrderAllCases() {
        XCTAssertEqual(SortOrder.allCases.count, 2)
        XCTAssertTrue(SortOrder.allCases.contains(.newestFirst))
        XCTAssertTrue(SortOrder.allCases.contains(.oldestFirst))
    }
}
