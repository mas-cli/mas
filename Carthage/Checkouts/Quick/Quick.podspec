Pod::Spec.new do |s|
  s.name         = "Quick"
  s.version      = "2.0.0"
  s.summary      = "The Swift (and Objective-C) testing framework."

  s.description  = <<-DESC
                   Quick is a behavior-driven development framework for Swift and Objective-C. Inspired by RSpec, Specta, and Ginkgo.
                   DESC

  s.homepage     = "https://github.com/Quick/Quick"
  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }

  s.author       = "Quick Contributors"
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = '9.0'

  s.source       = { :git => "https://github.com/Quick/Quick.git", :tag => "v#{s.version}" }
  s.source_files = "Sources/**/*.{swift,h,m}"

  s.public_header_files = [
    'Sources/QuickObjectiveC/Configuration/QuickConfiguration.h',
    'Sources/QuickObjectiveC/DSL/QCKDSL.h',
    'Sources/QuickObjectiveC/Quick.h',
    'Sources/QuickObjectiveC/QuickSpec.h',
  ]

  s.exclude_files = [
    'Sources/Quick/Configuration/QuickConfiguration.swift',
    'Sources/Quick/QuickSpec.swift',
    'Sources/Quick/QuickMain.swift',
  ]

  s.framework = "XCTest"
  s.requires_arc = true
  s.user_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '$(PLATFORM_DIR)/Developer/Library/Frameworks' }
  s.pod_target_xcconfig = {
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
    'ENABLE_BITCODE' => 'NO',
    'OTHER_LDFLAGS' => '$(inherited) -Xlinker -no_application_extension',
  }
  
  s.cocoapods_version = '>= 1.4.0'
  s.swift_version = '4.2'
end
