class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      tag:      "v1.8.2",
      revision: "2f2a43b425498f3cee50974116b8c9d27adbb7cb"
  license "MIT"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://github.com/mas-cli/mas/releases/download/v1.8.2"
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "76d7de5e7891f049c84f079b09c25f88576d45813651bdc529a8af4660c8efa0"
    sha256 cellar: :any_skip_relocation, big_sur:       "76d7de5e7891f049c84f079b09c25f88576d45813651bdc529a8af4660c8efa0"
    sha256 cellar: :any_skip_relocation, catalina:      "76d7de5e7891f049c84f079b09c25f88576d45813651bdc529a8af4660c8efa0"
    sha256 cellar: :any_skip_relocation, mojave:        "76d7de5e7891f049c84f079b09c25f88576d45813651bdc529a8af4660c8efa0"
    sha256 cellar: :any_skip_relocation, high_sierra:   "76d7de5e7891f049c84f079b09c25f88576d45813651bdc529a8af4660c8efa0"
    sha256 cellar: :any_skip_relocation, sierra:        "76d7de5e7891f049c84f079b09c25f88576d45813651bdc529a8af4660c8efa0"
    sha256 cellar: :any_skip_relocation, el_capitan:    "76d7de5e7891f049c84f079b09c25f88576d45813651bdc529a8af4660c8efa0"
  end

  depends_on :macos
  if Hardware::CPU.arm?
    depends_on xcode: ["12.2", :build]
  else
    depends_on xcode: ["12.0", :build]
  end

  def install
    system "script/build", "--universal"
    system "script/install", "--universal", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
    fish_completion.install "contrib/completion/mas.fish"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
    assert_includes shell_output("#{bin}/mas info 497799835"), "Xcode"
  end
end
