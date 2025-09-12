class E2b < Formula
  desc "CLI to manage E2B sandboxes and templates"
  homepage "https://e2b.dev"
  url "https://registry.npmjs.org/@e2b/cli/-/cli-2.1.0.tgz"
  sha256 "de10feb57f1dd63ee9b2bacc88926cc45ad6fcad333554088b5b2452d826958c"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, all: "42c723610d3473dfeb13cba94d94c0a19764c142bf8b111b01eeafc876db6794"
  end

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/e2b --version")
    assert_match "Not logged in", shell_output("#{bin}/e2b auth info")
  end
end
