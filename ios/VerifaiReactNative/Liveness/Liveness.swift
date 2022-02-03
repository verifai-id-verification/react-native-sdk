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
                            let data = try self.encoder.encode(result)
                            let json = String(data: data, encoding: .utf8) ?? "Unable to create success object"
                            self.handleSuccess(message: json)
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
    
}
