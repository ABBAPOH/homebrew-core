class Proxygen < Formula
  desc "Collection of C++ HTTP libraries"
  homepage "https://github.com/facebook/proxygen"
  url "https://github.com/facebook/proxygen/releases/download/v2025.08.25.00/proxygen-v2025.08.25.00.tar.gz"
  sha256 "e7397cbe93bb8567438f033bc5b1e407b074061c72783d3f55388e416b63fcf0"
  license "BSD-3-Clause"
  head "https://github.com/facebook/proxygen.git", branch: "main"

  bottle do
    sha256                               arm64_sequoia: "fa88f8a4d249437e9bd7213b299ec3492a728d3fb1c9451a7791789e76df04eb"
    sha256                               arm64_sonoma:  "ec1a4f7f0e4f6b16a8be15b4b4777a969e08bde42fc3170d7a3da91f9ae96e17"
    sha256                               arm64_ventura: "aad6a0f38acb601ca37cccb5d1fd3d9e76f9da8d0816b57b5a65aa2bded5e10a"
    sha256 cellar: :any,                 sonoma:        "1f2d75555ac3c6bb644cd4de3b9f83821ba9b1276695a819602ee69fcdfb95b9"
    sha256 cellar: :any,                 ventura:       "707b37f044ec643d1a86e9b3201fbee5a3df34e39a0fdc48b755921f9713ba57"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "217c2edfb832bb2b63d5445826e55d502c15fe7d4c874eb4d12f423ec90e03a3"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "947bbd8191ad9867e0487fb2d24229d1fb385dfd6f9259ddaebff8ef858c1bcb"
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "c-ares"
  depends_on "double-conversion"
  depends_on "fizz"
  depends_on "fmt"
  depends_on "folly"
  depends_on "gflags"
  depends_on "glog"
  depends_on "mvfst"
  depends_on "openssl@3"
  depends_on "wangle"
  depends_on "zstd"

  uses_from_macos "gperf" => :build
  uses_from_macos "python" => :build
  uses_from_macos "zlib"

  conflicts_with "hq", because: "both install `hq` binaries"

  # Fix build with Boost 1.89.0, pr ref: https://github.com/facebook/proxygen/pull/570
  patch do
    url "https://github.com/facebook/proxygen/commit/10af948d7ff29bc8601e83127a9d9ab1c441fc58.patch?full_index=1"
    sha256 "161937c94727ab34976d5f2f602e6b7fcaecc7c86236ce0f6cbd809a5f852379"
  end

  # Fix various symbol resolution errors.
  # https://github.com/facebook/proxygen/pull/572
  patch do
    url "https://github.com/facebook/proxygen/commit/7ad708b2206e4400240af5fd08e429b1b0cbedb3.patch?full_index=1"
    sha256 "4e64f687017888af90c4c6e691923db75c1e067fc8b722b038d05ee67707767c"
  end

  def install
    args = ["-DBUILD_SHARED_LIBS=ON", "-DCMAKE_INSTALL_RPATH=#{rpath}"]
    if OS.mac?
      args += [
        "-DCMAKE_EXE_LINKER_FLAGS=-Wl,-dead_strip_dylibs",
        "-DCMAKE_SHARED_LINKER_FLAGS=-Wl,-dead_strip_dylibs",
      ]
    end

    system "cmake", "-S", ".", "-B", "_build", *args, *std_cmake_args
    system "cmake", "--build", "_build"
    system "cmake", "--install", "_build"
  end

  test do
    port = free_port
    pid = spawn(bin/"proxygen_echo", "--http_port", port.to_s)
    sleep 30
    sleep 30 if OS.mac? && Hardware::CPU.intel?
    system "curl", "-v", "http://localhost:#{port}"
  ensure
    Process.kill "TERM", pid
  end
end
