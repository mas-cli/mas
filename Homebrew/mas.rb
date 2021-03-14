class Mas < Formula
  desc "Mac App Store command-line interface"
  homepage "https://github.com/mas-cli/mas"
  url "https://github.com/mas-cli/mas.git",
      tag:      "v1.8.0",
      revision: "9eaf57a5de836ce5e5435a8df14da4aa1b7d7444"
  license "MIT"
  head "https://github.com/mas-cli/mas.git"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "9667e4236b0afadd58eb02047ef4be19a5a9265cea49a89ddd794a29adefbe6e"
    sha256 cellar: :any_skip_relocation, big_sur:       "2b6527d04527d0900000b41ed501eed11d9b3cfec65328efa7f48427ce197c24"
    sha256 cellar: :any_skip_relocation, catalina:      "b50bdef7eb4fbf4d963d3b57879be5b97094e68c9d7372ec3103da246b21ff9e"
    sha256 cellar: :any_skip_relocation, mojave:        "04e225d74595e2ecef0d5aefb24edd32171a6368b2bdc22957dab43f46925d3d"
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
