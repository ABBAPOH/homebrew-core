class Vsd < Formula
  desc "Download video streams over HTTP, DASH (.mpd), and HLS (.m3u8)"
  homepage "https://github.com/clitic/vsd"
  url "https://github.com/clitic/vsd/archive/refs/tags/vsd-0.4.0.tar.gz"
  sha256 "06d76e3456c850c8add63db5c8650dfabafb27879dc3b4c461e1123e950a5fb0"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "pkgconf" => :build
  depends_on "protobuf" => :build
  depends_on "rust" => :build
  depends_on "ffmpeg"

  on_linux do
    depends_on "openssl@3"
  end

  def install
    ENV["OPENSSL_DIR"] = Formula["openssl@3"].opt_prefix
    ENV["OPENSSL_NO_VENDOR"] = "1"

    inreplace "vsd/Cargo.toml" do |s|
      s.gsub! ", path = \"../mp4decrypt\"", ""
      s.gsub! ", path = \"../vsd-mp4\"", ""
    end

    system "cargo", "install", *std_cargo_args(path: "vsd")
  end

  test do
    test_url = "http://maitv-vod.lab.eyevinn.technology/VINN.mp4/master.m3u8"
    output = testpath/"sample.mp4"

    system bin/"vsd", "save", test_url, "-o", output
    assert_path_exists output
    assert_operator output.size, :>, 0
  end
end
