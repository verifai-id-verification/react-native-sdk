//
//  Liveness.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 20/01/2022.
//

import Foundation
import VerifaiLivenessKit

@objc(Liveness)
public class Liveness: NSObject {
    
    // MARK: - Properties
    private let encoder = JSONEncoder()
    
    // MARK: - Listeners
    private var onSuccessListener: RCTResponseSenderBlock?
    private var onErrorListener: RCTResponseSenderBlock?
    
    /// On success listener for the Core
    /// - Parameter listener: The success listener
    @objc(setOnSuccess:)
    public func setOnSuccess(_ listener: @escaping RCTResponseSenderBlock) {
        self.onSuccessListener = listener
    }
    
    /// Handle the success call by checking if there's a listener and otherwise informing
    /// the dev via a print if this is not the case
    /// - Parameter message: The response message to be sent trough the listener
    private func handleSuccess(message: NSDictionary) {
        guard let onSuccessListener = onSuccessListener else {
            print("No success listener has been set, please set one")
            return
        }
        onSuccessListener([message])
    }
    
    /// Set On Error listener for the Core
    /// - Parameter listener: The error listener
    @objc(setOnError:)
    public func setOnError(_ listener: @escaping RCTResponseSenderBlock) {
        self.onErrorListener = listener
    }
    
    /// Handle the error call by checking if there's a listener and otherwise informing
    /// the dev via a print if this is not the case
    /// - Parameter message: The response message to be sent trough the listener
    private func handleError(message: String) {
        guard let onErrorListener = onErrorListener else {
            print("No error listener has been set, please set one")
            return
        }
        onErrorListener([message])
    }
    
    // MARK: - Liveness Module functions
    @objc(start:)
    public func start(_ configuration: NSDictionary) {
        // Run Liveness (on the main thread because it's going to be doing UI activities)
        DispatchQueue.main.async {
            // Use React function to get current top view controller
            guard let currentVC = RCTPresentedViewController() else {
                self.handleError(message: "🚫 No current view controller found")
                return
            }
            do {
                // Setup the configuration
                let nativeConf = try LivenessConfiguration(configuration: configuration)
                let requirements = nativeConf.requirements ?? VerifaiLiveness.defaultRequirements()
                // Setup the output directory where results will be kept
                if let outputUrl = nativeConf.resultOutputDirectory {
                    try FileManager.default.createDirectory(at: outputUrl,
                                                            withIntermediateDirectories: true,
                                                            attributes: nil)
                }
                // Start the liveness check
                try VerifaiLiveness.start(over: currentVC,
                                          requirements: requirements,
                                          resultOutputDirectory: nativeConf.resultOutputDirectory,
                                          showDismissButton: nativeConf.showDismissButton,
                                          customDismissButtonTitle: nativeConf.customDismissButtonTitle,
                                          resultBlock: { livenessResult in
                    switch livenessResult {
                    case .success(let result):
                        do {
                            self.handleSuccess(message: try self.prepareLivenessResult(result: result))
                        } catch {
                            self.handleError(message: "🚫 Unhandled error: \(error)")
                        }
                    case .failure(let error):
                        self.handleError(message: "🚫 Liveness check failed: \(error)")
                    }
                })
            } catch {
                self.handleError(message: "🚫 Unhandled error: \(error)")
            }
            
        }
    }
    
    /// Prepare Liveness result into something react native can understand
    /// - Parameter result: The result coming from the Liveness module
    private func prepareLivenessResult(result: VerifaiLivenessCheckResults) throws -> NSDictionary {
        // Goal is to transform the codable object into JSON data and then use native iOS
        // conversion to NSDictionary
        let data = try self.encoder.encode(result)
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .fragmentsAllowed) as? [String: Any] else  {
            throw RNError.unableToCreateResult
        }
        return NSDictionary(dictionary: dictionary)
    }
    
}
