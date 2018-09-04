def run(env = {}, command)
  system(env, command) or raise "RAKE TASK FAILED: #{command}"
end

def has_xcodebuild
  system "which xcodebuild >/dev/null"
end

def xcode_action
  ENV["XCODE_ACTION"] || "build test"
end

namespace "podspec" do
  desc "Run lint for podspec"
  task :lint do
    run "bundle exec pod lib lint"
  end
end

namespace "test" do
  desc "Run unit tests for all iOS targets"
  task :ios do |t|
    run "xcodebuild -workspace Quick.xcworkspace -scheme Quick-iOS -destination 'platform=iOS Simulator,name=iPhone 6' clean #{xcode_action}"
  end

  desc "Run unit tests for all tvOS targets"
  task :tvos do |t|
    run "xcodebuild -workspace Quick.xcworkspace -scheme Quick-tvOS -destination 'platform=tvOS Simulator,name=Apple TV 1080p' clean #{xcode_action}"
  end

  desc "Run unit tests for all macOS targets"
  task :macos do |t|
    run "xcodebuild -workspace Quick.xcworkspace -scheme Quick-macOS clean #{xcode_action}"
  end

  desc "Run unit tests for the current platform built by the Swift Package Manager"
  task :swiftpm do |t|
    env = { "SWIFT_PACKAGE_TEST_Quick" => "true" }
    run env, "swift package clean && swift test"
  end
end

namespace "templates" do
  install_dir = File.expand_path("~/Library/Developer/Xcode/Templates/File Templates/Quick")
  src_dir = File.expand_path("../Quick Templates", __FILE__)

  desc "Install Quick templates"
  task :install do
    if File.exists? install_dir
      raise "RAKE TASK FAILED: Quick templates are already installed at #{install_dir}"
    else
      mkdir_p install_dir
      cp_r src_dir, install_dir
    end
  end

  desc "Uninstall Quick templates"
  task :uninstall do
    rm_rf install_dir
  end
end

if has_xcodebuild then
  task default: ["test:ios", "test:tvos", "test:macos"]
else
  task default: ["test:swiftpm"]
end
