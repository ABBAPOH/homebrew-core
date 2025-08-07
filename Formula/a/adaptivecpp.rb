class Adaptivecpp < Formula
  desc "SYCL and C++ standard parallelism for CPUs and GPUs"
  homepage "https://adaptivecpp.github.io/"
  url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/v25.02.0.tar.gz"
  sha256 "8cc8a3be7bb38f88d7fd51597e0ec924b124d4233f64da62a31b9945b55612ca"
  license "BSD-2-Clause"
  head "https://github.com/AdaptiveCpp/AdaptiveCpp.git", branch: "develop"

  bottle do
    sha256 arm64_sequoia: "8cb6f094a3fbf0f910601703c6d7e65831b8e568967e5a66ebfa950a98b0a968"
    sha256 arm64_sonoma:  "8d9a08397ebf84cbbd09d37aca3b75464e3ee888a01d509aa8271dedf4dfbcbc"
    sha256 arm64_ventura: "3c6e4a92536c76c3b791a5c905d37d5f1d61e392f0dce155cf9720ece150aa83"
    sha256 sonoma:        "28388ca4a208e7e7d116bbbb4fb91458fa6217632db3579e9d3cf2ae2d4c4485"
    sha256 ventura:       "3571494508ad1edb0f2f7636613b6c200725befa53190239d95a6b2cc5579a36"
    sha256 arm64_linux:   "dd452feb307577a151f2132bc2c3508c26c44249d57a1445970dc7ee850591cc"
    sha256 x86_64_linux:  "fbd4be61d9ad7377b5a54884ad1feeb4b4bf0e12df662d81ba0387100ce586c5"
  end

  depends_on "cmake" => :build
  depends_on "boost"
  depends_on "llvm"
  uses_from_macos "python"

  on_macos do
    depends_on "libomp"
  end

  def install
    args = []
    if OS.mac?
      libomp_root = Formula["libomp"].opt_prefix
      args << "-DOpenMP_ROOT=#{libomp_root}"
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    # Avoid references to Homebrew shims directory
    inreplace prefix/"etc/AdaptiveCpp/acpp-core.json", Superenv.shims_path/ENV.cxx, ENV.cxx

    if OS.mac?
      # we add -I#{libomp_root}/include to default-omp-cxx-flags
      inreplace prefix/"etc/AdaptiveCpp/acpp-core.json",
                "\"default-omp-cxx-flags\" : \"",
                "\"default-omp-cxx-flags\" : \"-I#{libomp_root}/include "
    else
      # Move tools to work around brew's non-executable audit
      (lib/"hipSYCL/llvm-to-backend").install (bin/"hipSYCL/llvm-to-backend").children
    end
  end

  test do
    system bin/"acpp", "--version"

    (testpath/"hellosycl.cpp").write <<~C
      #include <sycl/sycl.hpp>
      int main(){
          sycl::queue q{};
      }
    C
    system bin/"acpp", "hellosycl.cpp", "-o", "hello"
    system "./hello"
  end
end
