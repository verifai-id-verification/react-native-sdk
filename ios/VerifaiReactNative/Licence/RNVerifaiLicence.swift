//
//  RNVerifaiLicence.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 06/01/2022.
//

import Foundation
import VerifaiCommonsKit

@objc(RNVerifaiLicence)
class RNVerifaiLicence: NSObject {
  
  /// Set the Verifai Licence
  /// - Parameter licence: The licence registered to the company
  @objc(setLicence:resolver:rejecter:)
  func setLicence(_ licence: String,
                  resolve: RCTPromiseResolveBlock,
                  reject: RCTPromiseRejectBlock) {
    switch VerifaiCommons.setLicence(licence) {
        case .success(_):
            resolve("Successfully configured Verifai")
        case .failure(let error):
            reject("","🚫 Licence error: \(error)", error)
    }
  }
}
