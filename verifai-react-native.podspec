require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "verifai-react-native"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "12.0" }
  s.source       = { :git => "https://github.com/verifai-id-verification/react-native-sdk", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm,swift}"

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.dependency 'React-Core'
  s.dependency 'Verifai', '~> 6.0.1'
  s.dependency 'VerifaiNFC', '~> 6.0.1'
  s.dependency 'VerifaiLiveness', '~> 6.0.1'
end
