//
//  ContentViewModel.swift
//  MemoryStatus
//
//  Created by Minyoung Yoo on 11/21/26.
//

import Foundation
import ServiceManagement
import SwiftUI

enum PressureLevel: Sendable {
    case normal
    case warning
    case critical
    case unknown
}

@MainActor
@Observable
final class ContentViewModel {
    var pressureLevel: PressureLevel = .unknown
    var statusText: String = "0.0 / 0 GB"

    var usedGBText: String = "0.0"
    var freeGBText: String = "0.0"
    var wiredGBText: String = "0.0"
    var compressedGBText: String = "0.0"
    var compressionRatioText: String = "0.0"

    private let memoryMonitor = MemoryMonitorActor()
    private var updateTask: Task<Void, Never>?
    private var pressureSource: (any DispatchSourceMemoryPressure)?

    init() {
        setupPressureSource()
        startMonitoring()
    }
    
    var launchAtLogin: Bool {
        get {
            SMAppService.mainApp.status == .enabled
        }
        set {
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Setting Launch at Login Failed: \(error.localizedDescription)")
            }
        }
    }

    private func setupPressureSource() {
        pressureSource = DispatchSource.makeMemoryPressureSource(
            eventMask: [.normal, .warning, .critical],
            queue: .main
        )
        pressureSource?.setEventHandler { [weak self] in
            guard let self = self else { return }
            let level = self.pressureSource?.data ?? .normal
            self.updatePressureLevel(level)
        }
        pressureSource?.resume()
    }

    private func updatePressureLevel(_ level: DispatchSource.MemoryPressureEvent) {
        if level == [] {
            pressureLevel = .normal
        } else if level.contains(.critical) {
            pressureLevel = .critical
        } else if level.contains(.warning) {
            pressureLevel = .warning
        } else {
            pressureLevel = .normal
        }
    }

    private func updatePressureLevel(_ sample: MemoryInfo) {
        let usedRatio = Double(sample.usedBytes) / Double(sample.totalBytes)
        if usedRatio > 0.9 {
            pressureLevel = .critical
        } else if usedRatio > 0.75 {
            pressureLevel = .warning
        } else {
            pressureLevel = .normal
        }
    }

    private func startMonitoring() {
        updateTask = Task { [weak self] in
            while !Task.isCancelled {
                let sample = await self?.memoryMonitor.sampleMemory()
                // Capture sample values to avoid sending self to MainActor.run
                let formatted = sample?.formatted()
                let used = String(format: "%.1f", sample?.usedGB() ?? "0.0")
                let free = String(format: "%.1f", Double(sample?.freeBytes ?? 0) / 1_073_741_824.0)
                let wired = String(format: "%.1f", Double(sample?.wiredBytes ?? 0) / 1_073_741_824.0)
                let compressed = String(format: "%.1f", Double(sample?.compressedBytes ?? 0) / 1_073_741_824.0)
                let ratio = String(format: "%.1f", sample?.compressionRatio ?? 0)
                let usedRatio = Double(sample?.usedBytes ?? 0) / Double(sample?.totalBytes ?? 0)
                
                await MainActor.run {
                    self?.statusText = formatted ?? "Unknown"
                    self?.usedGBText = used
                    self?.freeGBText = free
                    self?.wiredGBText = wired
                    self?.compressedGBText = compressed
                    self?.compressionRatioText = ratio
                    if usedRatio > 0.9 {
                        self?.pressureLevel = .critical
                    } else if usedRatio > 0.75 {
                        self?.pressureLevel = .warning
                    } else {
                        self?.pressureLevel = .normal
                    }
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}
