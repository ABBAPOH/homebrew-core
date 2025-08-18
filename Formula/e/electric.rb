class Electric < Formula
  desc "Real-time sync for Postgres"
  homepage "https://electric-sql.com"
  url "https://github.com/electric-sql/electric/archive/refs/tags/@core/sync-service@1.1.3.tar.gz"
  sha256 "e6ec40afde0607269b4e2af0982416594856d96d4ac82abf6186841893c0a730"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "0594bb01b210fc0c1c570dfa5180073c74b36db405c8b10ec7ccdab38a5053f7"
    sha256 cellar: :any,                 arm64_sonoma:  "4febe53eedadd799bf42f8a6dcac9d8650bdf852aa62429f7413d94f3bb2b97a"
    sha256 cellar: :any,                 arm64_ventura: "9229f4723b1b36f639bdf760e215db1e29c05ebb128f534efe63cede0d7bfbbf"
    sha256 cellar: :any,                 sonoma:        "ea720036c74582ac13a65b25fbc22c82d362a75b190451bc343c1507c36944f7"
    sha256 cellar: :any,                 ventura:       "8d7120aad5deccc40cb66807d5c985b2c1cc7df2f5f78ea72d10823552b18f62"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "8d1e1ed31a1922c552f2d88594d062cb502eca71fc6532ebceb273dd8fb57217"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4c720c93cb2a166494fb843e98317431232716ab305665b1f5635dd7b3a4173f"
  end

  depends_on "elixir" => :build
  depends_on "postgresql@17" => :test
  depends_on "erlang"
  depends_on "openssl@3"

  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  def install
    ENV["MIX_ENV"] = "prod"
    ENV["MIX_TARGET"] = "application"

    cd "packages/sync-service" do
      system "mix", "deps.get"
      system "mix", "compile"
      system "mix", "release"
      libexec.install Dir["_build/application_prod/rel/electric/*"]
      bin.write_exec_script libexec.glob("bin/*")
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/electric version")

    ENV["LC_ALL"] = "C"

    postgresql = Formula["postgresql@17"]
    pg_ctl = postgresql.opt_bin/"pg_ctl"
    port = free_port

    system pg_ctl, "initdb", "-D", testpath/"test"
    (testpath/"test/postgresql.conf").write <<~EOS, mode: "a+"
      port = #{port}
      wal_level = logical
    EOS
    system pg_ctl, "start", "-D", testpath/"test", "-l", testpath/"log"

    begin
      ENV["DATABASE_URL"] = "postgres://#{ENV["USER"]}:@localhost:#{port}/postgres?sslmode=disable"
      ENV["ELECTRIC_INSECURE"] = "true"
      ENV["ELECTRIC_PORT"] = free_port.to_s
      spawn bin/"electric", "start"

      output = shell_output("curl -s --retry 5 --retry-connrefused localhost:#{ENV["ELECTRIC_PORT"]}/v1/health")
      assert_match "active", output
    ensure
      system pg_ctl, "stop", "-D", testpath/"test"
    end
  end
end
