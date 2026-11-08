# The formula of kawadeomkar/homebrew-tap (P1-PKG-02). For the first release
# release.yml copies it into the tap as a pull request, with the tag's source
# archive and its checksum in place of the two placeholders; every later
# release bumps the tap's copy with `brew bump-formula-pr`. A change here
# reaches the tap only through a pull request there.
class Duscope < Formula
  desc "Fast, queryable disk-usage analyzer with JSON output"
  homepage "https://github.com/kawadeomkar/duscope"
  url "https://github.com/kawadeomkar/duscope/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "e56a4a7a073a9e01b891e2e6a0e812140da62374cba3fff387c7f4bca0412819"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/kawadeomkar/duscope.git", branch: "main"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    root_url "https://ghcr.io/v2/kawadeomkar/tap"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "1c3445f246e7b050d06a6ca6962d47315c4ee698043df2019e48d5e0d55b40f9"
    sha256 cellar: :any,                 x86_64_linux: "67a1c1bebea12aef5dd990b91b9109aa28d125f2116305e616574ba127b38049"
  end

  depends_on "rust" => :build
  deny_network_access!

  def fetch
    system "cargo", "fetch", *std_cargo_fetch_args
  end

  def install
    # The root Cargo.toml is a workspace; the binary is the duscope package.
    system "cargo", "install", *std_cargo_args(path: "duscope")
    generate_completions_from_executable(bin/"duscope", "completions")
    (man1/"duscope.1").write Utils.safe_popen_read(bin/"duscope", "man")
  end

  test do
    (testpath/"a/big.bin").write "x" * 8192
    (testpath/"a/small.txt").write "01"
    output = shell_output("#{bin}/duscope top --files #{testpath}/a --json")
    # The path as duscope reports it: symbolic links in testpath resolved.
    assert_match "/a/big.bin", output
    assert_match '"ok":true', output
  end
end
