class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas/archive/v1.4.2.tar.gz"
  sha256 "f9a751ff84e6dcbaedd4b2ca95b3ca623c739fd3af0b6ca950c321f2ce840bfe"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://dl.bintray.com/phatblat/mas-bottles"
    cellar :any_skip_relocation
    sha256 "af5be6aa9902d9cfc2aa69dbf313441a7c201463d516face721f900ceae9556b" => :el_capitan
    sha256 "af5be6aa9902d9cfc2aa69dbf313441a7c201463d516face721f900ceae9556b" => :high_sierra
    sha256 "af5be6aa9902d9cfc2aa69dbf313441a7c201463d516face721f900ceae9556b" => :mojave
    sha256 "af5be6aa9902d9cfc2aa69dbf313441a7c201463d516face721f900ceae9556b" => :sierra
    sha256 "af5be6aa9902d9cfc2aa69dbf313441a7c201463d516face721f900ceae9556b" => :yosemite
  end

  depends_on :xcode => ["9.0", :build]

  def install
    # Install bundler, then use it to install gems used by project
    ENV["GEM_HOME"] = buildpath/"gem_home"
    system "gem", "install", "bundler"
    ENV.prepend_path "PATH", buildpath/"gem_home/bin"
    system "bundle", "install"
    system "bundle", "exec", "pod", "install"

    xcodebuild "-workspace", "mas-cli.xcworkspace",
               "-scheme", "mas-cli Release"
    bin.install "build/mas"

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
  end
end
