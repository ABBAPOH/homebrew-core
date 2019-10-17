class Bogofilter < Formula
  desc "Mail filter via statistical analysis"
  homepage "https://bogofilter.sourceforge.io"
  url "https://downloads.sourceforge.net/project/bogofilter/bogofilter-stable/bogofilter-1.2.5.tar.xz"
  sha256 "3248a1373bff552c500834adbea4b6caee04224516ae581fb25a4c6a6dee89ea"

  bottle do
    sha256 "97a2da30e1c196c31eadbe5a3404258c79fdc9caed9b7c1daba9497442b02aee" => :mojave
    sha256 "188368373c8bb9719a459b0f7905818dd4c8ce4303a59152cd47cc43557ff10b" => :high_sierra
    sha256 "6366c9e1c254bbf94d2ada013d13fc78dc56c190e1ad148d5a0dded5bd263dbe" => :sierra
    sha256 "9c717b7628a0c0428528338880d6cd5d480b3246c3888cbab5a87d3b8b3689e2" => :el_capitan
  end

  depends_on "berkeley-db"

  def install
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/bogofilter", "--version"
  end
end
