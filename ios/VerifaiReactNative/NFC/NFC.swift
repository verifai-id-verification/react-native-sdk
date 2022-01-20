//
//  NFC.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 20/01/2022.
//

import Foundation

@objc(NFC)
public class NFC: NSObject {
  
  // MARK: - Listeners
  private var successListener: RCTResponseSenderBlock?
  private var errorListener: RCTResponseSenderBlock?
  
  /// On success listener for the Core
  /// - Parameter listener: The success listener
  @objc(setOnSuccess:)
  public func setOnSuccess(_ listener: @escaping RCTResponseSenderBlock) {
    self.successListener = listener
  }
  
  /// Handle the success call by checking if there's a listener and otherwise informing
  /// the dev via a print if this is not the case
  /// - Parameter message: The response message to be sent trough the listener
  private func handleSuccess(message: String) {
    guard let successListener = successListener else {
      print("No success listener has been set, please set one")
      return
    }
    successListener([message])
  }
  
  /// On cancel listener for the Core, iOS does not currently use this but we have it to have ensure interface equality
  /// with android. Otherwise a react crash could occur
  /// - Parameter listener: The cancel listener
  @objc(setOnCancelled:)
  public func setOnCancelled(_ listener: @escaping RCTResponseSenderBlock) { }
  
  /// Set On Error listener for the Core
  /// - Parameter listener: The error listener
  @objc(setOnError:)
  public func setOnError(_ listener: @escaping RCTResponseSenderBlock) {
    self.errorListener = listener
  }
  
  /// Handle the error call by checking if there's a listener and otherwise informing
  /// the dev via a print if this is not the case
  /// - Parameter message: The response message to be sent trough the listener
  private func handleError(message: String) {
    guard let errorListener = errorListener else {
      print("No error listener has been set, please set one")
      return
    }
    errorListener([message])
  }
  
}
