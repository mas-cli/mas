#
# Commandant.podspec
# Commandant
#

# Be sure to run `pod spec lint Commandant.podspec' to ensure this spec is valid before committing.
#
# To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html

Pod::Spec.new do |s|
  s.name         = "Commandant"
  s.version      = "0.15.0"
  s.summary      = "Type-safe command line argument handling"
  s.description  = <<-DESC
Commandant is a Swift framework for parsing command-line arguments, inspired by Argo
(which is, in turn, inspired by the Haskell library Aeson).
                   DESC

  s.homepage     = "https://github.com/Carthage/Commandant"
  s.license      = { type: "MIT", file: "LICENSE.md" }
  s.authors      = { "Carthage contributors" => "https://github.com/Carthage/Commandant/graphs/contributors" }

  s.platform     = :osx, "10.9"
  s.source       = { git: "https://github.com/Carthage/Commandant.git", tag: s.version }

  s.source_files  = "Sources/**/*.swift"

  s.dependency "Result", "~> 4.0"

  s.cocoapods_version = ">= 1.4.0"
  s.swift_version = "4.2"
end
