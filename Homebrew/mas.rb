class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      :tag      => "v1.5.0",
      :revision => "ccaaa74c9593d04dc41fcff40af196fdad49f517"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    cellar :any
    sha256 "d3668e4d128dfc8e062adc30c543ded35e7726dd9e021696e32a97d484e465fd" => :mojave
    sha256 "fc6658113d785a660e3f4d2e4e134ad02fe003ffa7d69271a2c53f503aaae726" => :high_sierra
  end

  depends_on "carthage" => :build
  depends_on :xcode => ["10.1", :build]
  depends_on "trash"

  def install
    # Working around build issues in dependencies
    # - Prevent warnings from causing build failures
    # - Prevent linker errors by telling all lib builds to use max size install names
    xcconfig = buildpath/"Overrides.xcconfig"
    xcconfig.write <<~EOS
      GCC_TREAT_WARNINGS_AS_ERRORS = NO
      OTHER_LDFLAGS = -headerpad_max_install_names
    EOS
    ENV["XCODE_XCCONFIG_FILE"] = xcconfig

    system "carthage", "bootstrap", "--platform", "macOS"
    system "script/install", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
  end
end
