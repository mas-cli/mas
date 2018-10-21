class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      :tag => "v1.4.3",
      :revision => "11a0e3e14e5a83aaaba193dfb6d18aa49a82b881"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://dl.bintray.com/phatblat/mas-bottles"
    cellar :any_skip_relocation
    sha256 "84a34f9e4458b7bed57e013cc85ecb1df5fa165d458fed3a9e8c4a9ac43baada" => :mojave
    sha256 "84a34f9e4458b7bed57e013cc85ecb1df5fa165d458fed3a9e8c4a9ac43baada" => :high_sierra
    sha256 "84a34f9e4458b7bed57e013cc85ecb1df5fa165d458fed3a9e8c4a9ac43baada" => :sierra
    sha256 "84a34f9e4458b7bed57e013cc85ecb1df5fa165d458fed3a9e8c4a9ac43baada" => :el_capitan
    sha256 "84a34f9e4458b7bed57e013cc85ecb1df5fa165d458fed3a9e8c4a9ac43baada" => :yosemite
    sha256 "84a34f9e4458b7bed57e013cc85ecb1df5fa165d458fed3a9e8c4a9ac43baada" => :mavericks
  end

  depends_on "carthage" => :build
  depends_on :xcode => ["10.0", :build]

  def install
    # Prevent warnings from causing build failures
    # Prevent linker errors by telling all lib builds to use max size install names
    xcconfig = buildpath/"Overrides.xcconfig"
    xcconfig.write <<~EOS
      GCC_TREAT_WARNINGS_AS_ERRORS = NO
      OTHER_LDFLAGS = -headerpad_max_install_names
    EOS
    ENV["XCODE_XCCONFIG_FILE"] = xcconfig

    system "carthage", "bootstrap", "--platform", "macOS"

    xcodebuild "install",
                "-project", "mas-cli.xcodeproj",
                "-scheme", "mas-cli Release",
                "-configuration", "Release",
                "OBJROOT=build",
                "SYMROOT=build"

    system "script/install", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
  end
end
