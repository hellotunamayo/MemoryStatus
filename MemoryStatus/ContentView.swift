//
//  ContentView.swift
//  MemoryStatus
//
//  Created by Minyoung Yoo on 11/21/26.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @State var monitor: ContentViewModel
    
    var pressureColor: Color {
        switch monitor.pressureLevel {
            case .unknown:
                return .gray
            case .warning:
                return .yellow
            case .normal:
                return .green
            case .critical:
                return .red
        }
    }
    
    var pressureText: String {
        switch monitor.pressureLevel {
            case .unknown:
                return "Unknown"
            case .warning:
                return "Warning"
            case .normal:
                return "Normal"
            case .critical:
                return "Critical"
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("\(pressureText)").foregroundStyle(pressureColor)
                Text("\(monitor.statusText)")
            }

            Divider()

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Used:").foregroundStyle(.secondary)
                    Text("\(monitor.usedGBText) GB")
                        .foregroundColor(.white)
                }
                .font(.body)
                
                HStack {
                    Text("Free:").foregroundStyle(.secondary)
                    Text("\(monitor.freeGBText) GB")
                        .foregroundColor(.white)
                }
                .font(.body)
                
                HStack {
                    Text("Wired:").foregroundStyle(.secondary)
                    Text("\(monitor.wiredGBText) GB")
                        .foregroundColor(.white)
                }
                .font(.body)
                
                HStack {
                    Text("Compressed:").foregroundStyle(.secondary)
                    Text("\(monitor.compressedGBText) GB (\(monitor.compressionRatioText)%)")
                        .foregroundColor(.white)
                }
                .font(.body)
            }

            Divider()
            
            Toggle("Launch at Login", isOn: $monitor.launchAtLogin)
                .toggleStyle(.switch)
            
            Divider()

            Button(action: {
                openApp(bundleIdentifier: "com.apple.ActivityMonitor")
            }) {
                Label("Open Activity Monitor", systemImage: "gauge.with.dots.needle.100percent")
                    .padding(.vertical, 3)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("m", modifiers: [.command])

            Button(action: {
                exit(0)
            }) {
                Label("Quit Memory Monitor", systemImage: "xmark.circle.fill")
                    .padding(.vertical, 3)
            }
            .buttonStyle(.plain)
            .keyboardShortcut("q", modifiers: [.command])
        }
        .padding()
    }

    func openApp(bundleIdentifier: String) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) else {
            print("App not found")
            return
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { app, error in
            if let error = error {
                print("Failed to open app: \(error.localizedDescription)")
            }
        }
    }
}
