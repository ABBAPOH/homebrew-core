class Rulesync < Formula
  desc "Unified AI rules management CLI tool"
  homepage "https://github.com/dyoshikawa/rulesync"
  url "https://registry.npmjs.org/rulesync/-/rulesync-0.69.0.tgz"
  sha256 "4c00863a46e8db0c206dfb842e371d968354223aa45c3d3aa6c03f8116203045"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "1a7534454f21da61513829ca9a8e7fe0314c8fd4321d5fdce10023c405926444"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rulesync --version")

    output = shell_output("#{bin}/rulesync init")
    assert_match "rulesync initialized successfully", output
    assert_match "Project overview and general development guidelines", (testpath/".rulesync/rules/overview.md").read
  end
end
