//
//  NFC.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 20/01/2022.
//

import Foundation
import VerifaiNFCKit
import VerifaiCommonsKit
import VerifaiKit

@objc(NFC)
public class NFC: NSObject {

    // MARK: - Properties
    private var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        // Setup the encoder before returning it
        encoder.dateEncodingStrategy = .iso8601
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

    // MARK: - NFC Configuration
    @objc
    public func configure(_ configuration: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        do {
            var coreConfiguration =  VerifaiCoreConfiguration()
            if let coreConfigurationDict = configuration.value(forKey: "core") as? NSDictionary {
                coreConfiguration = try CoreConfiguration(configuration: coreConfigurationDict).nativeConfiguration
            }
          
            var nfcConfiguration = VerifaiNFCConfiguration()
            if let nfcConfigurationDict = configuration.value(forKey: "nfc") as? NSDictionary {
                nfcConfiguration = try NFCConfiguration(configuration: nfcConfigurationDict).nativeConfiguration
            }
          
            try VerifaiNFC.configure(coreConfiguration: coreConfiguration, nfcConfiguration: nfcConfiguration)
            resolve(nil)
        } catch {
            reject(ErrorType.configuration, "🚫 Verifai not correctly configured", error)
        }
    }

    // MARK: - NFC
    @objc
    public func startLocal(_ resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Run NFC (on the main thread because it's going to be doing UI activities)
        DispatchQueue.main.async {
            do {
                // Use React function to get current top view controller
                guard let currentVC = RCTPresentedViewController() else {
                    reject(ErrorType.noView, "🚫 No current view controller found", nil)
                    return
                }
                // Start the NFC module
                try VerifaiNFC.startLocal(over: currentVC,
                                          resultBlock: { nfcResult in
                    switch nfcResult {
                    case .failure(let error):
                        var errorType = ErrorType.sdk
                        if (error is VerifaiFlowCancelError) {
                            errorType = ErrorType.canceled
                        }
                        reject(errorType, "🚫 \(error)", error)
                    case .success(let result):
                        do {
                            let preparedResult = try prepareNFCResult(result: result)
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

    // MARK: - NFC API Flow
    @objc
    public func start(_ internalReference: String, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            do {
                // Use React function to get current top view controller
                guard let currentVC = RCTPresentedViewController() else {
                    reject(ErrorType.noView, "🚫 No current view controller found", nil)
                    return
                }
                // Start Verifai NFC API Route
                try VerifaiNFC.start(over: currentVC, internalReference: internalReference, resultBlock: { result in
                    switch result {
                    case .failure(let error):
                        var errorType = ErrorType.sdk
                        if (error is VerifaiFlowCancelError) {
                            errorType = ErrorType.canceled
                        }
                        reject(errorType, "🚫 \(error)", error)
                    case .success(let verifaiNfcAPIResult):
                        do {
                            let preparedResult = try prepareAPINFCResult(nfcAPIResult: verifaiNfcAPIResult)
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
