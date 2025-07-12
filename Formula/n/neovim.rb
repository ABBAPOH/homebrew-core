class Neovim < Formula
  desc "Ambitious Vim-fork focused on extensibility and agility"
  homepage "https://neovim.io/"
  license "Apache-2.0"

  head "https://github.com/neovim/neovim.git", branch: "master"

  stable do
    url "https://github.com/neovim/neovim/archive/refs/tags/v0.11.3.tar.gz"
    sha256 "7f1ce3cc9fe6c93337e22a4bc16bee71e041218cc9177078bd288c4a435dbef0"

    # Keep resources updated according to:
    # https://github.com/neovim/neovim/blob/v#{version}/cmake.deps/CMakeLists.txt

    # TODO: Consider shipping these as separate formulae instead. See discussion at
    #       https://github.com/orgs/Homebrew/discussions/3611
    # NOTE: The `install` method assumes that the parser name follows the final `-`.
    #       Please name the resources accordingly.
    resource "tree-sitter-c" do
      url "https://github.com/tree-sitter/tree-sitter-c/archive/refs/tags/v0.24.1.tar.gz"
      sha256 "25dd4bb3dec770769a407e0fc803f424ce02c494a56ce95fedc525316dcf9b48"
    end

    resource "tree-sitter-lua" do
      url "https://github.com/tree-sitter-grammars/tree-sitter-lua/archive/refs/tags/v0.4.0.tar.gz"
      sha256 "b0977aced4a63bb75f26725787e047b8f5f4a092712c840ea7070765d4049559"
    end

    resource "tree-sitter-vim" do
      url "https://github.com/tree-sitter-grammars/tree-sitter-vim/archive/refs/tags/v0.7.0.tar.gz"
      sha256 "44eabc31127c4feacda19f2a05a5788272128ff561ce01093a8b7a53aadcc7b2"
    end

    resource "tree-sitter-vimdoc" do
      url "https://github.com/neovim/tree-sitter-vimdoc/archive/refs/tags/v4.0.0.tar.gz"
      sha256 "8096794c0f090b2d74b7bff94548ac1be3285b929ec74f839bd9b3ff4f4c6a0b"
    end

    resource "tree-sitter-query" do
      url "https://github.com/tree-sitter-grammars/tree-sitter-query/archive/refs/tags/v0.6.2.tar.gz"
      sha256 "90682e128d048fbf2a2a17edca947db71e326fa0b3dba4136e041e096538b4eb"
    end

    resource "tree-sitter-markdown" do
      url "https://github.com/tree-sitter-grammars/tree-sitter-markdown/archive/refs/tags/v0.5.0.tar.gz"
      sha256 "14c2c948ccf0e9b606eec39b09286c59dddf28307849f71b7ce2b1d1ef06937e"
    end
  end

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  no_autobump! because: :requires_manual_review

  bottle do
    sha256 arm64_sequoia: "4daf9a69527c6243feaf66c3ce0d01f5fc6f6ff962988a561663ddb01a3c36cf"
    sha256 arm64_sonoma:  "619883a9f10ea00f97840b378cc56019690662d1542c1cef0732b5c8f20e3a4d"
    sha256 arm64_ventura: "09abebe3fa78456c1230ca07d105c02f36badf67621e7352697631b5d81d8b9f"
    sha256 sonoma:        "5cc8afa4275ecb1be1cc9aa9f1ca9950ec446b96d585bcc8fa9a979980872a3c"
    sha256 ventura:       "ac255cd6a40ec1a9a397c8e522c193fddea8b5bdf533dc64f42128830a13a247"
    sha256 arm64_linux:   "8eb7d15a777726fea9a9863ef39dc6d93527fcdc9b648ee7b514e0f46d9166fd"
    sha256 x86_64_linux:  "b80a6adba844e455f42b63df79eb965cf38934c99114c38c2ac9382a862e0c3b"
  end

  depends_on "cmake" => :build
  depends_on "gettext"
  depends_on "libuv"
  depends_on "lpeg"
  depends_on "luajit"
  depends_on "luv"
  depends_on "tree-sitter"
  depends_on "unibilium"
  depends_on "utf8proc"

  def install
    if build.head?
      cmake_deps = (buildpath/"cmake.deps/deps.txt").read.lines
      cmake_deps.each do |line|
        next unless line.match?(/TREESITTER_[^_]+_URL/)

        parser, parser_url = line.split
        parser_name = parser.delete_suffix("_URL")
        parser_sha256 = cmake_deps.find { |l| l.include?("#{parser_name}_SHA256") }.split.last
        parser_name = parser_name.downcase.tr("_", "-")

        resource parser_name do
          url parser_url
          sha256 parser_sha256
        end
      end
    end

    resources.each do |r|
      source_directory = buildpath/"deps-build/build/src"/r.name
      build_directory = buildpath/"deps-build/build"/r.name

      parser_name = r.name.split("-").last
      cmakelists = case parser_name
      when "markdown" then "MarkdownParserCMakeLists.txt"
      else "TreesitterParserCMakeLists.txt"
      end

      r.stage(source_directory)
      cp buildpath/"cmake.deps/cmake"/cmakelists, source_directory/"CMakeLists.txt"

      system "cmake", "-S", source_directory, "-B", build_directory, "-DPARSERLANG=#{parser_name}", *std_cmake_args
      system "cmake", "--build", build_directory
      system "cmake", "--install", build_directory
    end

    # Point system locations inside `HOMEBREW_PREFIX`.
    inreplace "src/nvim/os/stdpaths.c" do |s|
      s.gsub! "/etc/xdg/", "#{etc}/xdg/:\\0"

      if HOMEBREW_PREFIX.to_s != HOMEBREW_DEFAULT_PREFIX
        s.gsub! "/usr/local/share/:/usr/share/", "#{HOMEBREW_PREFIX}/share/:\\0"
      end
    end

    # Replace `-dirty` suffix in `--version` output with `-Homebrew`.
    inreplace "cmake/GenerateVersion.cmake", "--dirty", "--dirty=-Homebrew"

    args = [
      "-DLUV_LIBRARY=#{Formula["luv"].opt_lib/shared_library("libluv")}",
      "-DLIBUV_LIBRARY=#{Formula["libuv"].opt_lib/shared_library("libuv")}",
      "-DLPEG_LIBRARY=#{Formula["lpeg"].opt_lib/shared_library("liblpeg")}",
    ]
    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    refute_match "dirty", shell_output("#{bin}/nvim --version")
    (testpath/"test.txt").write("Hello World from Vim!!")
    system bin/"nvim", "--headless", "-i", "NONE", "-u", "NONE",
                       "+s/Vim/Neovim/g", "+wq", "test.txt"
    assert_equal "Hello World from Neovim!!", (testpath/"test.txt").read.chomp
  end
end
