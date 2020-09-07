def run(env = {}, command)
  system(env, command) or raise "RAKE TASK FAILED: #{command}"
end

def has_xcodebuild
  system "which xcodebuild >/dev/null"
end

def xcode_action
  ENV["XCODE_ACTION"] || "build-for-testing test-without-building"
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
    run "set -o pipefail && xcodebuild -workspace Quick.xcworkspace -scheme Quick-iOS -destination 'generic/platform=iOS' OTHER_SWIFT_FLAGS='$(inherited) -suppress-warnings' clean build | xcpretty"
    run "set -o pipefail && xcodebuild -workspace Quick.xcworkspace -scheme Quick-iOS -destination 'platform=iOS Simulator,name=iPhone 8' OTHER_SWIFT_FLAGS='$(inherited) -suppress-warnings' clean #{xcode_action} | xcpretty"
  end

  desc "Run unit tests for all tvOS targets"
  task :tvos do |t|
    run "set -o pipefail && xcodebuild -workspace Quick.xcworkspace -scheme Quick-tvOS -destination 'generic/platform=tvOS' OTHER_SWIFT_FLAGS='$(inherited) -suppress-warnings' clean build | xcpretty"
    run "set -o pipefail && xcodebuild -workspace Quick.xcworkspace -scheme Quick-tvOS -destination 'platform=tvOS Simulator,name=Apple TV' OTHER_SWIFT_FLAGS='$(inherited) -suppress-warnings' clean #{xcode_action} | xcpretty"
  end

  desc "Run unit tests for all macOS targets"
  task :macos do |t|
    run "set -o pipefail && xcodebuild -workspace Quick.xcworkspace -scheme Quick-macOS OTHER_SWIFT_FLAGS='$(inherited) -suppress-warnings' clean #{xcode_action} | xcpretty"
  end

  desc "Run unit tests for all macOS targets using static linking"
  task :macos_static do |t|
    run "set -o pipefail && MACH_O_TYPE=staticlib xcodebuild -workspace Quick.xcworkspace -scheme Quick-macOS OTHER_SWIFT_FLAGS='$(inherited) -suppress-warnings' clean #{xcode_action} | xcpretty"
  end

  desc "Run unit tests for the current platform built by the Swift Package Manager"
  task :swiftpm do |t|
    run "swift package clean && swift test -Xswiftc -suppress-warnings"
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
