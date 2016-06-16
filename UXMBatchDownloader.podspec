#
# Be sure to run `pod lib lint UXMBatchDownloader.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UXMBatchDownloader'
  s.version          = '0.1.5'
  s.summary          = 'Easily download massive numbers of files.'

  s.description      = <<-DESC
UXMBatchDownloader simplifies the arduous task of handling hundreds of file downloads concurrently without worrying about timeouts.
                       DESC

  s.homepage         = 'https://github.com/uxmstudio/UXMBatchDownloader'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Chris Anderson' => 'chris@uxmstudio.com' }
  s.source           = { :git => 'https://github.com/uxmstudio/UXMBatchDownloader.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'UXMBatchDownloader/Classes/**/*'

end
