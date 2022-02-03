//
//  NFC.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 20/01/2022.
//

import Foundation
import VerifaiNFCKit

@objc(NFC)
public class NFC: NSObject {
    
    // MARK: - Properties
    private let encoder = JSONEncoder()
    
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
    
    // MARK: - NFC Module functions
    @objc(start:)
    public func start(_ configuration: NSDictionary) {
        // Make sure there's a result
        guard let currentResult = VerifaiResultSingleton.shared.currentResult else {
            handleError(message: "🚫 No result yet, please do a normal scan first")
            return
        }
        // Run NFC (on the main thread because it's going to be doing UI activities)
        DispatchQueue.main.async {
            // Use React function to get current top view controller
            guard let currentVC = RCTPresentedViewController() else {
                self.handleError(message: "🚫 No current view controller found")
                return
            }
            do {
                // NFC configuration from the dictionary
                let settings = try NFCConfiguration(configuration: configuration)
                // Start the NFC module
                try VerifaiNFC.start(over: currentVC,
                                     documentData: currentResult,
                                     retrieveImage: settings.retrieveImage,
                                     showDismissButton: settings.showDismissButton,
                                     customDismissButtonTitle: settings.customDismissButtonTitle,
                                     instructionScreenConfiguration: settings.instructionScreenConfiguration,
                                     scanHelpConfiguration: settings.scanHelpConfiguration)
                { nfcResult in
                    switch nfcResult {
                    case .failure(let error):
                        self.handleError(message: "🚫 Error or cancellation: \(error)")
                    case .success(let result):
                        do {
                            // Keep the NFC image in singleton in case the liveness check needs it
                            VerifaiResultSingleton.shared.nfcImage = result.photo
                            // Process result to a format react-native can understand (JSON string)
                            let preparedResult = try self.prepareNFCResult(result: result)
                            self.handleSuccess(message: preparedResult)
                        } catch {
                            self.handleError(message: "🚫 Error parsing result: \(error)")
                        }
                    }
                }
            } catch {
                self.handleError(message: "🚫 Unhandled error: \(error)")
            }
        }
    }
    
    /// Prepare NFC result into something react native can understand
    /// - Parameter result: The result coming from the NFC module
    private func prepareNFCResult(result: VerifaiNFCResult) throws -> String {
      // Front image
      let data = try self.encoder.encode(VerifaiNFCReactNativeResult(nfcResult: result))
      return String(data: data, encoding: .utf8) ?? "Unable to create success object"
    }
    
}
