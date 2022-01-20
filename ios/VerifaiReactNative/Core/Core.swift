//
//  Core.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 06/01/2022.
//

import UIKit
import VerifaiCommonsKit
import VerifaiKit

@objc(Core)
public class Core: NSObject {
  
  // MARK: - Properties
  private let encoder = JSONEncoder()
  private let globalConfiguration = VerifaiConfiguration()
  
  // MARK: - Listeners
  private var successListener: RCTResponseSenderBlock?
  private var errorListener: RCTResponseSenderBlock?
  
  
  /// On success listener for iOS
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
  
  /// On cancel listener for iOS, iOS does not currently use this but we have it to have ensure interface equality
  /// with android. Otherwise a react crash could occur
  /// - Parameter listener: The cancel listener
  @objc(setOnCancelled:)
  public func setOnCancelled(_ listener: @escaping RCTResponseSenderBlock) { }
  
  /// Set On Error listener for iOS
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
  
  // MARK: - Licence
  /// Set the Verifai Licence
  /// - Parameter licence: The licence registered to the company
  @objc(setLicence:)
  public func setLicence(_ licence: String) {
    switch VerifaiCommons.setLicence(licence) {
    case .success(_):
      dump("Successfully configured Verifai")
    case .failure(let error):
      // Error setting the licence inform the listener
     handleError(message: "🚫 Licence error: \(error)")
    }
  }
  
  // MARK: - Configuration
  
  /// Setup the Verifai configuration based on a javascript dictionary
  /// - Parameter configuration: A dictionary with key value pairs that link
  /// to configuration values
  @objc(configure:)
  public func configure(_ configuration: NSDictionary) {
    dump(configuration)
    // Main settings
    if let requireDocumentCopy = configuration.value(forKey: "requireDocumentCopy") as? Bool {
      globalConfiguration.requireDocumentCopy = requireDocumentCopy
    }
    if let requireCroppedImage = configuration.value(forKey: "requireCroppedImage") as? Bool {
      globalConfiguration.requireCroppedImage = requireCroppedImage
    }
    if let enablePostCropping = configuration.value(forKey: "enablePostCropping") as? Bool {
      globalConfiguration.enablePostCropping = enablePostCropping
    }
    if let enableManual = configuration.value(forKey: "enableManual") as? Bool {
      globalConfiguration.enableManual = enableManual
    }
    if let requireMRZContents = configuration.value(forKey: "requireMRZContents") as? Bool {
      globalConfiguration.requireMRZContents = requireMRZContents
    }
    if let readMRZContents = configuration.value(forKey: "readMRZContents") as? Bool {
      globalConfiguration.readMRZContents = readMRZContents
    }
    if let requireNFCWhenAvailable = configuration.value(forKey: "requireNFCWhenAvailable") as? Bool {
      globalConfiguration.requireNFCWhenAvailable = requireNFCWhenAvailable
    }
    if let enableVisualInspection = configuration.value(forKey: "enableVisualInspection") as? Bool {
      globalConfiguration.enableVisualInspection = enableVisualInspection
    }
    if let documentFiltersAutoCreateValidators = configuration.value(
      forKey: "documentFiltersAutoCreateValidators") as? Bool {
      globalConfiguration.documentFiltersAutoCreateValidators = documentFiltersAutoCreateValidators
    }
    if let scanDuration = configuration.value(forKey: "scanDuration") as? Double {
      globalConfiguration.scanDuration = scanDuration
    }
    if let customDismissButtonTitle = configuration.value(forKey: "customDismissButtonTitle") as? String {
      globalConfiguration.customDismissButtonTitle = customDismissButtonTitle
    }
    if let documentFiltersAutoCreateValidators = configuration.value(
      forKey: "documentFiltersAutoCreateValidators") as? Bool {
      globalConfiguration.documentFiltersAutoCreateValidators = documentFiltersAutoCreateValidators
    }
    
    globalConfiguration.instructionScreenConfiguration = try! VerifaiInstructionScreenConfiguration(showInstructionScreens: false)
    
    try! Verifai.configure(with: globalConfiguration)
    
    
    //    public var validators: [VerifaiKit.VerifaiValidator]
    //
    //    public var documentFilters: [VerifaiKit.VerifaiDocumentFilter]
    
    
    
    //    public var instructionScreenConfiguration: VerifaiKit.VerifaiInstructionScreenConfiguration
    //
    //    public var scanHelpConfiguration: VerifaiKit.VerifaiScanHelpConfiguration
  }
  
  // MARK: - Core
  @objc(start)
  public func start() {
    DispatchQueue.main.async {
      do {
        // Use React function to get current top view controller
        guard let currentVC = RCTPresentedViewController() else {
          self.handleError(message: "🚫 No current view controller found")
          return
        }
        // Start Verifai
        try Verifai.start(over: currentVC) { result in
          switch result {
          case .failure(let error):
            self.handleError(message: "🚫 Licence error: \(error)")
          case .success(let verifaiResult):
            // Process result to a format react-native can understand (JSON string)
            do {
              let preparedResult = try self.prepareCoreResult(result: verifaiResult)
              self.handleSuccess(message: preparedResult)
            } catch {
              self.handleError(message: "🚫 Result conversion error: \(error)")
            }
          }
        }
      } catch {
        self.handleError(message: "🚫 Unhandled error: \(error)")
      }
    }
  }
  
  /// Prepare core result into something react native can understand
  /// - Parameter result: The result coming from the core
  private func prepareCoreResult(result: VerifaiResult) throws -> String {
    // Front image
    let data = try self.encoder.encode(VerifaiReactNativeResult(result: result))
    return String(data: data, encoding: .utf8) ?? "Unable to create success object"
  }
  
  
}
