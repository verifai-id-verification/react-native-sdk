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
    private var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        // Setup the encoder before returning it
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
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
#if DEBUG
            print("No success listener has been set, please set one")
#endif
            return
        }
        onSuccessListener([message])
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
        self.onErrorListener = listener
    }
    
    /// Handle the error call by checking if there's a listener and otherwise informing
    /// the dev via a print if this is not the case
    /// - Parameter message: The response message to be sent trough the listener
    private func handleError(message: String) {
        guard let onErrorListener = onErrorListener else {
#if DEBUG
            print("No error listener has been set, please set one")
#endif
            return
        }
        onErrorListener([message])
    }
    
    // MARK: - Licence
    /// Set the Verifai Licence
    /// - Parameter licence: The licence registered to the company
    @objc(setLicence:)
    public func setLicence(_ licence: String) {
        switch VerifaiCommons.setLicence(licence) {
        case .success(_):
#if DEBUG
            dump("Successfully configured Verifai")
#endif
        case .failure(let error):
            // Error setting the licence inform the listener
            handleError(message: "🚫 Error: \(error)")
        }
    }
    
    // MARK: - Configuration
    
    /// Setup the Verifai configuration based on a javascript dictionary
    /// - Parameter configuration: A dictionary with key value pairs that link
    /// to configuration values
    @objc(configure:)
    public func configure(_ configuration: NSDictionary) {
        do {
            // Setup the core's configuration
            let coreConfiguration = try CoreConfiguration(configuration:configuration)
            // Set it
            try Verifai.configure(with: coreConfiguration.globalConfiguration)
        } catch {
            handleError(message: "🚫 Error in configuration: \(error)")
        }
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
                        self.handleError(message: "🚫 Error: \(error)")
                    case .success(let verifaiResult):
                        do {
                            // Save the result so that it can be used by other modules
                            VerifaiResultSingleton.shared.currentResult = verifaiResult
                            // Process result to a format react-native can understand (NSDictionary)
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
    private func prepareCoreResult(result: VerifaiResult) throws -> NSDictionary {
        // Goal is to transform the codable object into JSON data and then use native iOS
        // conversion to NSDictionary
        let data = try self.encoder.encode(VerifaiReactNativeResult(result: result))
        guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                                options: .fragmentsAllowed) as? [String: Any] else  {
            throw RNError.unableToCreateResult
        }
        return NSDictionary(dictionary: dictionary)
    }
    
    // Main queue setup not required
    @objc(requiresMainQueueSetup)
    public static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
