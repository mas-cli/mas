class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      tag:      "v1.8.1",
      revision: "23a36b4555f5625fe29915b31b8b101064452dca"
  license "MIT"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://dl.bintray.com/phatblat/mas-bottles"
    sha256 cellar: :any, arm64_big_sur: "d54d864976f78665d5175fd9e69ab81b3911fa28fd6ae627b61a18d55d68191a"
    sha256 cellar: :any, big_sur:       "d54d864976f78665d5175fd9e69ab81b3911fa28fd6ae627b61a18d55d68191a"
    sha256 cellar: :any, catalina:      "d54d864976f78665d5175fd9e69ab81b3911fa28fd6ae627b61a18d55d68191a"
    sha256 cellar: :any, mojave:        "d54d864976f78665d5175fd9e69ab81b3911fa28fd6ae627b61a18d55d68191a"
    sha256 cellar: :any, high_sierra:   "d54d864976f78665d5175fd9e69ab81b3911fa28fd6ae627b61a18d55d68191a"
    sha256 cellar: :any, sierra:        "d54d864976f78665d5175fd9e69ab81b3911fa28fd6ae627b61a18d55d68191a"
    sha256 cellar: :any, el_capitan:    "d54d864976f78665d5175fd9e69ab81b3911fa28fd6ae627b61a18d55d68191a"
  end

  depends_on :macos
  if Hardware::CPU.arm?
    depends_on xcode: ["12.2", :build]
  else
    depends_on xcode: ["11.4", :build]
  end

  def install
    system "script/install", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
    fish_completion.install "contrib/completion/mas.fish"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
    assert_include shell_output("#{bin}/mas info 497799835"), "Xcode"
  end
end
