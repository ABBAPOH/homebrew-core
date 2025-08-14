class Cadence < Formula
  desc "Resource-oriented smart contract programming language"
  homepage "https://cadence-lang.org/"
  url "https://github.com/onflow/cadence/archive/refs/tags/v1.6.5.tar.gz"
  sha256 "dfbdeb2bf54c12a01636e7d32decf73ffc4d369ac963686ae1b3c6556314af2c"
  license "Apache-2.0"
  head "https://github.com/onflow/cadence.git", branch: "master"

  # Upstream uses GitHub releases to indicate that a version is released
  # (there's also sometimes a notable gap between when a version is tagged and
  # and the release is created), so the `GithubLatest` strategy is necessary.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "2573ee60062a593f9379df4626324afabfd2491bca01af2c859c714cdd81096d"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "2573ee60062a593f9379df4626324afabfd2491bca01af2c859c714cdd81096d"
    sha256 cellar: :any_skip_relocation, arm64_ventura: "2573ee60062a593f9379df4626324afabfd2491bca01af2c859c714cdd81096d"
    sha256 cellar: :any_skip_relocation, sonoma:        "a6a9d92703eb5da3eee97b6de59a33bc1c00e50add36c59e995315d716ea4a14"
    sha256 cellar: :any_skip_relocation, ventura:       "a6a9d92703eb5da3eee97b6de59a33bc1c00e50add36c59e995315d716ea4a14"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "68d1c2a9dbcc689b0b991cd960c27b6703b53997ad535845f1dbe61bb92b9126"
  end

  depends_on "go" => :build

  conflicts_with "cadence-workflow", because: "both install a `cadence` executable"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w"), "./cmd/main"
  end

  test do
    # from https://cadence-lang.org/docs/tutorial/hello-world
    (testpath/"hello.cdc").write <<~EOS
      access(all) contract HelloWorld {

          // Declare a public (access(all)) field of type String.
          //
          // All fields must be initialized in the initializer.
          access(all) let greeting: String

          // The initializer is required if the contract contains any fields.
          init() {
              self.greeting = "Hello, World!"
          }

          // Public function that returns our friendly greeting!
          access(all) view fun hello(): String {
              return self.greeting
          }
      }
    EOS
    system bin/"cadence", "hello.cdc"
  end
end
