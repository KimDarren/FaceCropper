#
# Be sure to run `pod lib lint FaceCropper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FaceCropper'
  s.version          = '1.0.0'
  s.summary          = 'Crop faces, inside of your image, with Vision'
  s.homepage         = 'https://github.com/KimDarren/FaceCropper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'KimDarren' => 'korean.darren@gmail.com' }
  s.source           = { :git => 'https://github.com/KimDarren/FaceCropper.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'FaceCropper/Classes/**/*'
  s.frameworks = 'UIKit', 'Vision'
end
