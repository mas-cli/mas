class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      :tag      => "v1.7.0",
      :revision => "35575ff962687cfd9a12f859668cf61d5ea819c2"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://dl.bintray.com/phatblat/mas-bottles"
    cellar :any
    sha256 "adc9a2206f9fb5e7665cab7accea8ef682c382f35a8dabd8dd0cbd7bfbc82729" => :catalina
    sha256 "adc9a2206f9fb5e7665cab7accea8ef682c382f35a8dabd8dd0cbd7bfbc82729" => :mojave
    sha256 "adc9a2206f9fb5e7665cab7accea8ef682c382f35a8dabd8dd0cbd7bfbc82729" => :high_sierra
    sha256 "adc9a2206f9fb5e7665cab7accea8ef682c382f35a8dabd8dd0cbd7bfbc82729" => :sierra
    sha256 "adc9a2206f9fb5e7665cab7accea8ef682c382f35a8dabd8dd0cbd7bfbc82729" => :el_capitan
  end

  depends_on "carthage" => :build
  depends_on :xcode => ["10.2", :build]

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

    # Only build necessary dependencies
    system "carthage", "bootstrap", "--platform", "macOS", "Commandant"
    system "script/install", prefix

    bash_completion.install "contrib/completion/mas-completion.bash" => "mas"
    fish_completion.install "contrib/completion/mas.fish"
  end

  test do
    assert_equal version.to_s, shell_output("#{bin}/mas version").chomp
    assert_include shell_output("#{bin}/mas info 497799835"), "Xcode"
  end
end
