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
        // TODO: - to check
        //encoder.dataEncodingStrategy = .base64
        return encoder
    }()

    // MARK: - License
    /// Set the Verifai License
    /// - Parameter license: The license registered to the company
    @objc
    public func setLicense(_ license: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        switch VerifaiCommons.setLicense(license) {
        case .success(_):
            resolve(nil)
        case .failure(let error):
            reject(ErrorType.license, "🚫 \(error)", error)
        }
    }

    // MARK: - Configuration

    /// Setup the Verifai configuration based on a javascript dictionary
    /// - Parameter configuration: A dictionary with key value pairs that link
    /// to configuration values
    @objc
    public func configure(_ configuration: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        do {
            let coreConfiguration = try CoreConfiguration(configuration: configuration)
            try Verifai.configure(with: coreConfiguration.nativeConfiguration)
            resolve(nil)
        } catch {
            reject(ErrorType.configuration, "🚫 Verifai not correctly configured", error)
        }
    }

    // MARK: - Core
    @objc
    public func startLocal(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do {
                // Use React function to get current top view controller
                guard let currentVC = RCTPresentedViewController() else {
                    reject(ErrorType.noView, "🚫 No current view controller found", nil)
                    return
                }
                // Start Verifai
                try Verifai.startLocal(over: currentVC) { result in
                    switch result {
                    case .failure(let error):
                        var errorType = ErrorType.sdk
                        if (error is VerifaiFlowCancelError) {
                            errorType = ErrorType.canceled
                        }
                        reject(errorType, "🚫 \(error)", error)
                    case .success(let verifaiResult):
                        do {
                            let preparedResult = try prepareCoreResult(result: verifaiResult)
                            resolve(preparedResult)
                        } catch {
                            reject(ErrorType.resultConversion, "🚫 Result conversion error: \(error)", error)
                        }
                    }
                }
            } catch {
                reject(ErrorType.unhandled, "🚫 Unhandled error: \(error)", error)
            }
        }
    }

    // MARK: - Core API FLow
    @objc
    public func start(_ internalReference: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do {
                // Use React function to get current top view controller
                guard let currentVC = RCTPresentedViewController() else {
                    reject(ErrorType.noView, "🚫 No current view controller found", nil)
                    return
                }
                // Start Verifai API Route
                try Verifai.start(over: currentVC, internalReference: internalReference, resultBlock: { result in
                    switch result {
                    case .failure(let error):
                        var errorType = ErrorType.sdk
                        if (error is VerifaiFlowCancelError) {
                            errorType = ErrorType.canceled
                        }
                        reject(errorType, "🚫 \(error)", error)
                    case .success(let verifaiAPIResult):
                        do {
                            let preparedResult = try prepareAPICoreResult(coreAPIResult: verifaiAPIResult)
                            resolve(preparedResult)
                        } catch {
                            reject(ErrorType.resultConversion, "🚫 Result conversion error: \(error)", error)
                        }
                    }
                })
            } catch {
                reject(ErrorType.unhandled, "🚫 Unhandled error: \(error)", error)
            }
        }
    }

    // Main queue setup not required
    @objc(requiresMainQueueSetup)
    public static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
