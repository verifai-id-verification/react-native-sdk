//
//  VerifaiLocalCombinedReactNativeResult.swift
//  verifai-react-native
//
//  Created by Nadia Ruocco on 22/03/2023.
//

import Foundation
import VerifaiNFCKit

/// Combined Verifai Result with core scan and NFC scan results.
class VerifaiLocalCombinedReactNativeResult: Codable {
    
  var core: VerifaiReactNativeResult
  var nfc: VerifaiNFCReactNativeResult?
  var nfcError: VerifaiNFCError?
    
  init(core: VerifaiReactNativeResult, nfc: VerifaiNFCReactNativeResult?, error: VerifaiNFCError?) {
        self.core = core
        self.nfc = nfc
        self.nfcError = error
    }
}
