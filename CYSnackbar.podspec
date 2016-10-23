Pod::Spec.new do |s|
  s.name         = "CYSnackbar"
  s.version      = "0.1-alpha"
  s.summary      = "Snackbar for iOS."

  s.homepage     = "https://github.com/chaoyang805/CYSnackbar"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "chaoyang805" => "zhangchaoyang805@gmail.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/chaoyang805/CYSnackbar.git", :tag => "v0.1-alpha" }

  s.source_files  = "CYSnackbar", "CYSnackbar/**/*.{h,m,swift}"
  s.framework  = "UIKit"

end
