Pod::Spec.new do |s|
  s.name             = "TPTestPod"
  s.version          = "0.1.10"
  s.summary          = "TPTestPod is a simple testing pod to test pod_tools"
  s.homepage         = "http://tidepool.co"
  s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "e7mac" => "mayank.ot@gmail.com" }
  s.source           = { :git => "https://github.com/tidepool/TPTestPod.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/tidepool'

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resources = 'Assets/*'

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/*.h'
  s.frameworks = 'Foundation', 'SystemConfiguration', 'AdSupport'
  s.dependency 'AFNetworking', '~> 2.0'
  s.dependency 'SSKeychain', '~> 1.2'
  s.dependency 'Facebook-iOS-SDK', '3.13.1'
  s.dependency 'ReactiveCocoa', '~> 2.2'
  s.dependency 'Mantle', '~> 1.3'
end
