//
//  VerifaiResultSingleton.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 21/01/2022.
//

import Foundation
import VerifaiCommonsKit


/// Singleton that holds the latest verifai result as to
/// make the start of other modules that need result data easier.
/// There is also a clear function that will clear this result when it's no longer needed
@objc(VerifaiResultManager)
class VerifaiResultSingleton: NSObject {
  
  static let shared = VerifaiResultSingleton()
  
  var currentResult: VerifaiResult?
  
  @objc(clearResult)
  public func clearResult() {
    currentResult = nil
  }
  
}
