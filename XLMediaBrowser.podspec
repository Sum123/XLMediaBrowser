#
#  Be sure to run `pod spec lint XLMediaBrowser.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "XLMediaBrowser"
  spec.version      = "0.0.2"
  spec.summary      = "A short description of XLMediaBrowser."
  spec.description  = "图片浏览"
  spec.homepage     = "https://github.com/Sum123/XLMediaBrowser"
  spec.license      = ":type => 'MIT'"
  spec.author       = "Sum123"
  spec.platform     = :ios, "10.0"
  spec.source       = { :git => "https://github.com/Sum123/XLMediaBrowser.git", :tag => "0.02" }
  spec.source_files  = "Classes", "Classes/**/*.{h,m}"

  spec.source_files  = "XLMediaBrowser/*.{swift}"
  spec.dependency "SDWebImage"
  spec.dependency "SDWebImageFLPlugin"
  # spec.dependency 'SDWebImageWebPCoder'
  spec.dependency "DACircularProgress"
  
end
