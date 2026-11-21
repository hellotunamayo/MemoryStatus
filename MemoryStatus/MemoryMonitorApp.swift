import SwiftUI
import Foundation
import Combine

@main
struct MemoryMonitorApp: App {
    private var viewModel = ContentViewModel()
    
    private var statusEmoji: String {
            switch viewModel.pressureLevel {
            case .unknown:
                return "⚪️"
            case .normal:
                return "🟢"
            case .warning:
                return "🟡"
            case .critical:
                return "🔴"
            }
        }

    var body: some Scene {
        MenuBarExtra {
            ContentView(monitor: viewModel)
        } label: {
            Text("\(statusEmoji) \(viewModel.statusText)")
                .fontDesign(.monospaced)
        }
        .menuBarExtraStyle(.window)
    }
}


