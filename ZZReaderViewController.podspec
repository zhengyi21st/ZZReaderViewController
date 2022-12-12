Pod::Spec.new do |s|
  s.name        = "ZZReaderViewController"
  s.version     = "0.0.1"
  s.homepage    = "https://github.com/zhengyi21st/ZZReaderViewController"
  s.source = { :git => "https://github.com/zhengyi21st/ZZReaderViewController.git", :tag => s.version }
  s.license     = { :type => "MIT" }
  s.authors     = { "ethan" => "zhengyi21st@gmail.com" }
  s.summary     = "A short description of ZZReaderViewController."
  
  s.requires_arc = true
  s.swift_version = '5.0'
  s.ios.deployment_target = '11.0'
  s.source_files = "Sources/**/*.{swift}"
  
end
