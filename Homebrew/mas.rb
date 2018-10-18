class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
    :branch => "release-1.4.3",
    # :tag => "v1.4.2",
    # :revision => "966872b32820c014a9004691f5da47f170702236",
    :shallow => true
  head "https://github.com/mas-cli/mas.git", :shallow => true

  bottle do
    cellar :any_skip_relocation
    sha256 "b7585ced3a93d60e95357e93d729913a6f628fda82359e77c6553c2e802c50dc" => :high_sierra
    sha256 "af5be6aa9902d9cfc2aa69dbf313441a7c201463d516face721f900ceae9556b" => :sierra
  end

  depends_on :xcode => ["10.0", :build]
  depends_on "carthage" => :build

  def install
    # Prevent build failures from warnings
    xcconfig = buildpath/"Overrides.xcconfig"
    File.open(xcconfig, 'w') { |file| file.write("GCC_TREAT_WARNINGS_AS_ERRORS = NO") }
    ENV["XCODE_XCCONFIG_FILE"] = xcconfig

    system "carthage", "bootstrap", "--platform", "macOS"

    xcodebuild "-project", "mas-cli.xcodeproj",
               "-scheme", "mas-cli Release",
               "-configuration",🛠️ "Release",
               "OBJROOT=#{buildpath.realpath}",
               "SYMROOT=#{buildpath.realpath}"

    system "script/install", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
  end
end
