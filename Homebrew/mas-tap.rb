class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      tag:      "v1.8.0",
      revision: "9eaf57a5de836ce5e5435a8df14da4aa1b7d7444"
  license "MIT"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    root_url "https://dl.bintray.com/phatblat/mas-bottles"
    sha256 cellar: :any, arm64_big_sur: "444796f43ad88de2cc6f8effcde699330867ace7d722b367dd446dd75e1db251"
    sha256 cellar: :any, big_sur:       "444796f43ad88de2cc6f8effcde699330867ace7d722b367dd446dd75e1db251"
    sha256 cellar: :any, catalina:      "444796f43ad88de2cc6f8effcde699330867ace7d722b367dd446dd75e1db251"
    sha256 cellar: :any, mojave:        "444796f43ad88de2cc6f8effcde699330867ace7d722b367dd446dd75e1db251"
    sha256 cellar: :any, high_sierra:   "444796f43ad88de2cc6f8effcde699330867ace7d722b367dd446dd75e1db251"
    sha256 cellar: :any, sierra:        "444796f43ad88de2cc6f8effcde699330867ace7d722b367dd446dd75e1db251"
    sha256 cellar: :any, el_capitan:    "444796f43ad88de2cc6f8effcde699330867ace7d722b367dd446dd75e1db251"
  end

  depends_on "carthage" => :build
  if Hardware::CPU.arm?
    depends_on xcode: ["12.2", :build]
  else
    depends_on xcode: ["11.4", :build]
  end

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
