cask "memory_status" do
  version "1.0.0"
  sha256 "698d48c9ff70c97491dca2a558545a5c943911f3c7d8f49d4dccdfb348bc04b6"

  url "https://github.com/hellotunamayo/MemoryStatus/releases/download/1.0.0/MemoryStatus1.0.0.zip"
  name "MemoryStatus"
  desc "A macOS system tray utility for real-time memory monitoring"
  homepage "https://github.com/hellotunamayo/MemoryStatus"

  app "MemoryStatus.app"
end
