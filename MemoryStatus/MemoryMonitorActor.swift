import Foundation
import Darwin

// MARK: - Memory Info DTO
struct MemoryInfo: Sendable {
    let timestamp: Date
    let totalBytes: UInt64
    let usedBytes: UInt64
    let freeBytes: UInt64
    let wiredBytes: UInt64
    let activeBytes: UInt64
    let inactiveBytes: UInt64
    let compressedBytes: UInt64
    let compressionRatio: Double
}

// MARK: - Memory Monitor Actor
actor MemoryMonitorActor {
    private let pageSize: UInt64
    private let host: UInt32
    private let totalMemory: UInt64

    init() {
        // Use sysconf(_SC_PAGESIZE) instead of vm_page_size global for Swift 6 Sendable safety
        self.pageSize = UInt64(sysconf(_SC_PAGESIZE))
        self.host = mach_host_self()
        self.totalMemory = ProcessInfo.processInfo.physicalMemory
    }

    func sampleMemory() -> MemoryInfo {
        let vmStats = host_vm_statistics64()

        let free = UInt64(vmStats.free_count) * pageSize
        let active = UInt64(vmStats.active_count) * pageSize
        let inactive = UInt64(vmStats.inactive_count) * pageSize
        let wired = UInt64(vmStats.wire_count) * pageSize
        let compressed = UInt64(vmStats.compressor_page_count) * pageSize

        // Used memory calculation
        let used = active + wired + compressed

        let compressionRatio = free > 0 ? Double(compressed) / Double(free + compressed) * 100.0 : 0.0

        return MemoryInfo(
            timestamp: Date(),
            totalBytes: totalMemory,
            usedBytes: used,
            freeBytes: free,
            wiredBytes: wired,
            activeBytes: active,
            inactiveBytes: inactive,
            compressedBytes: compressed,
            compressionRatio: compressionRatio
        )
    }

    private func host_vm_statistics64() -> vm_statistics64 {
        let intCount = 39 // integer_t (int32)
        let byteSize = intCount * 4
        let ptr = UnsafeMutableRawPointer.allocate(byteCount: byteSize, alignment: 4)
        defer { ptr.deallocate() }
        
        var count: mach_msg_type_number_t = mach_msg_type_number_t(intCount)
        host_statistics64(host, HOST_VM_INFO64, ptr.assumingMemoryBound(to: integer_t.self), &count)
        
        var vmStats = vm_statistics64()
        withUnsafeMutableBytes(of: &vmStats) { target in
            target.copyMemory(from: UnsafeRawBufferPointer(start: ptr, count: byteSize))
        }
        return vmStats
    }
}

// MARK: - Format utilities
extension MemoryInfo {
    func usedGB() -> Double {
        Double(usedBytes) / 1_073_741_824.0
    }

    func totalGB() -> Double {
        Double(totalBytes) / 1_073_741_824.0
    }

    func formatted() -> String {
        let used = String(format: "%5.1f", usedGB())
        let total = String(format: "%.0f", totalGB())
        return "\(used) / \(total) GB"
    }
}
