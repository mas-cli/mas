class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      :tag      => "v1.6.2",
      :revision => "b3197cf3caa797aa8689cd15da3518cc7149d2ad"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://dl.bintray.com/phatblat/mas-bottles"
    cellar :any
    sha256 "451db10c91387ea9eb052b15331960508a94cc828a45e7fc62035e9793eabc04" => :mojave
    sha256 "451db10c91387ea9eb052b15331960508a94cc828a45e7fc62035e9793eabc04" => :high_sierra
    sha256 "451db10c91387ea9eb052b15331960508a94cc828a45e7fc62035e9793eabc04" => :sierra
    sha256 "451db10c91387ea9eb052b15331960508a94cc828a45e7fc62035e9793eabc04" => :el_capitan
  end

  depends_on "carthage" => :build
  depends_on :xcode => ["10.1", :build]

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
    assert_include shell_output("#{bin}/mas info 497799835"), "Xcode"
  end
end
