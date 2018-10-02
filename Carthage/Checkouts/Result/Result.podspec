Pod::Spec.new do |s|
  s.name         = 'Result'
  s.version      = '4.0.0'
  s.summary      = 'Swift type modelling the success/failure of arbitrary operations'

  s.homepage     = 'https://github.com/antitypical/Result'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Rob Rix' => 'rob.rix@github.com' }
  s.source       = { :git => 'https://github.com/antitypical/Result.git', :tag => s.version }
  s.source_files  = 'Result/*.swift'
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'
  
  s.swift_version = '4.0'
  s.cocoapods_version = '>= 1.4.0'
end
