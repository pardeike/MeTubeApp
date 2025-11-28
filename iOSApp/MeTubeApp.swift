import SwiftUI
import MeTube

@main
struct MeTubeApp: App {
    @State var model = VideoListViewModel()
    var body: some Scene {
        WindowGroup {
            VideoListView(viewModel: model)
        }
    }
}
