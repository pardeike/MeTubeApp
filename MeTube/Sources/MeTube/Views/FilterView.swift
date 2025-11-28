#if canImport(SwiftUI)
import SwiftUI

/// Filter controls view for the video list
public struct FilterView: View {
    @Binding var filter: VideoFilter
    let channels: [Channel]
    let onReset: () -> Void
    
    public init(filter: Binding<VideoFilter>, channels: [Channel], onReset: @escaping () -> Void) {
        self._filter = filter
        self.channels = channels
        self.onReset = onReset
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Status filters
                Section("Watch Status") {
                    Toggle("Unwatched", isOn: $filter.showUnwatched)
                    Toggle("Watched", isOn: $filter.showWatched)
                    Toggle("Skipped", isOn: $filter.showSkipped)
                }
                
                // Channel filter
                Section("Channel") {
                    Picker("Filter by Channel", selection: $filter.selectedChannelId) {
                        Text("All Channels")
                            .tag(nil as String?)
                        
                        ForEach(channels) { channel in
                            Text(channel.title)
                                .tag(channel.id as String?)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                // Sort order
                Section("Sort Order") {
                    Picker("Sort By", selection: $filter.sortOrder) {
                        ForEach(SortOrder.allCases) { order in
                            Label(order.displayName, systemImage: order.systemImage)
                                .tag(order)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Reset button
                Section {
                    Button("Reset to Defaults", role: .destructive) {
                        onReset()
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FilterView(
        filter: .constant(.defaultFilter),
        channels: Channel.mockChannels,
        onReset: {}
    )
}
#endif
