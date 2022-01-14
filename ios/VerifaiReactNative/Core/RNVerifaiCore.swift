//
//  RNVerifaiCore.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 06/01/2022.
//

import UIKit
import VerifaiCommonsKit
import VerifaiKit

@objc(RNVerifaiCore)
public class RNVerifaiCore: NSObject {
  
  // MARK: - Properties
  private let encoder = JSONEncoder()
  private let globalConfiguration = VerifaiConfiguration()
  
  // MARK: - Configuration
  
  /// Setup the Verifai configuration based on a javascript dictionary
  /// - Parameter configuration: A dictionary with key value pairs that link
  /// to configuration values
  @objc(setupConfiguration:)
  public func setupConfiguration(_ configuration: NSDictionary) {
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
    
    
    
    //    public var validators: [VerifaiKit.VerifaiValidator]
    //
    //    public var documentFilters: [VerifaiKit.VerifaiDocumentFilter]
    
    
    
    //    public var instructionScreenConfiguration: VerifaiKit.VerifaiInstructionScreenConfiguration
    //
    //    public var scanHelpConfiguration: VerifaiKit.VerifaiScanHelpConfiguration
  }
  
  // MARK: - Core
  @objc(start:reject:)
  public func start(resolve: @escaping RCTPromiseResolveBlock,
                    reject: @escaping RCTPromiseRejectBlock) {
    DispatchQueue.main.async {
      do {
        // Use React function to get current top view controller
        guard let currentVC = RCTPresentedViewController() else {
          reject("","🚫 No current view controller found", nil)
          return
        }
        // Start Verifai
        try Verifai.start(over: currentVC) { result in
          switch result {
          case .failure(let error):
            reject("","🚫 Licence error: \(error)", error)
          case .success(let verifaiResult):
            // Process result to a format react-native can understand (JSON string)
            do {
              let data = try self.encoder.encode(verifaiResult)
              resolve(String(data: data, encoding: .utf8))
            } catch {
              reject("","🚫 Result conversion error: \(error)", error)
            }
          }
        }
      } catch {
        print("🚫 Unhandled error: \(error)")
        reject("","🚫 Licence error: \(error)", error)
      }
    }
  }
}
