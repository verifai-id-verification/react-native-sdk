

Pod::Spec.new do |s|


  s.name         = "VerifaiNFC"
  s.version      = "5.1.1"
  s.summary      = "Verifai NFC component part of Verifai. ID verification SDK"

  s.description  = <<-DESC
  This is the Verifai NFC component. Which is part of the Verifai SDK. The main SDK is required when using this component. Verifai is extraordinarily smart OCR software, which can authenticate all types of identification documents in a matter of seconds.
                   DESC

  s.homepage     = "https://www.verifai.com"
  s.documentation_url = "https://docs.verifai.com"
  s.license      = { :type => "Commercial", :file => "LICENSE" }
  s.author             = { "Verifai" => "info@verifai.com" }
  s.platform     = :ios
  s.ios.deployment_target = "11.0"

  s.source       = { :http => "https://dashboard.verifai.com/downloads/sdk/nfc/5.1.1/verifai_sdk_nfc_5_1_1.zip", :sha1 => "2ab8d30cd55ad30e073567df9efdb0438cadbf46" }
  s.ios.vendored_frameworks = 'VerifaiNFCKit.xcframework'
end
