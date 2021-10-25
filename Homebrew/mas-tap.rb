class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      tag:      "v1.8.3",
      revision: "aeeb1c508e98d657769ef4e368a113be7822d92e"
  license "MIT"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://github.com/mas-cli/mas/releases/download/v1.8.3"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_monterey: "3be8fedcbe67571100d0ec45f9ed4d68a22db93e406806a4365568138dd33bb7"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "3be8fedcbe67571100d0ec45f9ed4d68a22db93e406806a4365568138dd33bb7"
    sha256 cellar: :any_skip_relocation, monterey:       "6b960f09c2214e4ff48d60b88147bcc0cdde5e2916c085d4fcfc622b7ef89b6b"
    sha256 cellar: :any_skip_relocation, big_sur:        "6b960f09c2214e4ff48d60b88147bcc0cdde5e2916c085d4fcfc622b7ef89b6b"
    sha256 cellar: :any_skip_relocation, catalina:       "6b960f09c2214e4ff48d60b88147bcc0cdde5e2916c085d4fcfc622b7ef89b6b"
    sha256 cellar: :any_skip_relocation, mojave:         "6b960f09c2214e4ff48d60b88147bcc0cdde5e2916c085d4fcfc622b7ef89b6b"
    sha256 cellar: :any_skip_relocation, high_sierra:    "6b960f09c2214e4ff48d60b88147bcc0cdde5e2916c085d4fcfc622b7ef89b6b"
    sha256 cellar: :any_skip_relocation, sierra:         "6b960f09c2214e4ff48d60b88147bcc0cdde5e2916c085d4fcfc622b7ef89b6b"
    sha256 cellar: :any_skip_relocation, el_capitan:     "6b960f09c2214e4ff48d60b88147bcc0cdde5e2916c085d4fcfc622b7ef89b6b"
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
