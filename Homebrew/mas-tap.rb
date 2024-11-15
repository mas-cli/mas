# typed: strict
# frozen_string_literal: true

# mas command formula for custom tap (mas-cli/homebrew-tap).
class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      tag:      "v1.8.7-beta.1",
      revision: "f8be3e9aaa6c78490277976f17041f2577f5dc21"
  license "MIT"
  head "https://github.com/mas-cli/mas.git", branch: "main"

  bottle do
    root_url "https://github.com/mas-cli/mas/releases/download/v1.8.7-beta.1"
    sha256 cellar: :any_skip_relocation, el_capitan: "0d042a450d2623e3ea40db0b645454ee88d1a1763a7aa778eec5beea619b9a60"
  end

  depends_on xcode: ["14.2", :build]
  depends_on :macos

  def install
    system "script/build"
    system "script/install", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
    fish_completion.install "contrib/completion/mas.fish"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
    assert_includes shell_output("#{bin}/mas info 497799835"), "Xcode"
  end
end
