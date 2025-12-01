import SwiftUI
import MeTube
#if canImport(UIKit)
import UIKit
#endif

@main
struct MeTubeApp: App {
    @State var model = VideoListViewModel()
    #if canImport(UIKit)
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    var body: some Scene {
        WindowGroup {
            VideoListView(viewModel: model)
        }
    }
}

#if canImport(UIKit)
/// App delegate to handle background task management
class AppDelegate: NSObject, UIApplicationDelegate {
    /// Background task identifier for extending sync time
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    /// Begin background task when app enters background to allow sync to complete
    func applicationDidEnterBackground(_ application: UIApplication) {
        beginBackgroundTask()
    }
    
    /// End background task when app becomes active
    func applicationDidBecomeActive(_ application: UIApplication) {
        endBackgroundTask()
    }
    
    private func beginBackgroundTask() {
        guard backgroundTaskID == .invalid else { return }
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "SyncSubscriptions") { [weak self] in
            // Called when background time is about to expire
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        guard backgroundTaskID != .invalid else { return }
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}
#endif
