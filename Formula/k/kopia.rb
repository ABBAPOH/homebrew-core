class Kopia < Formula
  desc "Fast and secure open-source backup"
  homepage "https://kopia.io"
  url "https://github.com/kopia/kopia.git",
      tag:      "v0.21.0",
      revision: "3a38279bcd7ace79369fc657b4b5d968d4b5b2f2"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "fef8724dc38183165b2d95d432d734a40b228d299615c5c2358ef6429b23f1d8"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "d1d69afba3a1d9046cb623472825ed7931a392b95355dad08ed6bfe06cbfd8de"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "831b07fa446facb10c136d177f99879e5fd11a4d044cbf84c30549496ed59f3a"
    sha256 cellar: :any_skip_relocation, sonoma:        "30e627dfd7fd3f7a3ccd73a1242c9ea0cde4620a953c5dfb7cf8791b68a417f7"
    sha256 cellar: :any_skip_relocation, ventura:       "3e37353a6c9a459b81755d2a45b5bab5e653e6e91c9891ff446fc10eec71619a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d281c76447834d789a567bc9c219b3971e071c5f8aab34646e118301b381abc5"
  end

  depends_on "go" => :build

  def install
    ldflags = %W[
      -s -w
      -X github.com/kopia/kopia/repo.BuildInfo=#{Utils.git_head}
      -X github.com/kopia/kopia/repo.BuildVersion=#{version}
    ]
    system "go", "build", *std_go_args(ldflags:)

    generate_completions_from_executable(bin/"kopia", shells:                 [:bash, :zsh],
                                                      shell_parameter_format: "--completion-script-")

    output = Utils.safe_popen_read(bin/"kopia", "--help-man")
    (man1/"kopia.1").write output
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kopia --version")

    mkdir testpath/"repo"
    (testpath/"testdir/testfile").write("This is a test.")

    ENV["KOPIA_PASSWORD"] = "dummy"

    system bin/"kopia", "repository", "create", "filesystem", "--path", testpath/"repo", "--no-persist-credentials"
    assert_path_exists testpath/"repo/kopia.repository.f"
    system bin/"kopia", "snapshot", "create", testpath/"testdir"
    system bin/"kopia", "snapshot", "list"
    system bin/"kopia", "repository", "disconnect"
  end
end
