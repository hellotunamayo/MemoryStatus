class MemoryStatus < Formula
  desc "A macOS system tray utility for real-time memory monitoring."
  homepage "https://github.com/hellotunamayo/MemoryStatus"
  url "https://github.com/hellotunamayo/homebrew-memory_status/releases/download/1.0.0/MemoryStatus1.0.0.zip"
  sha256 "698d48c9ff70c97491dca2a558545a5c943911f3c7d8f49d4dccdfb348bc04b6"

  def install
    app.install "MemoryStatus.app"
  end
end
