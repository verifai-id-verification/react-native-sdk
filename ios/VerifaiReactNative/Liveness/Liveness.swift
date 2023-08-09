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
    private var encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        // Setup the encoder before returning it
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    // MARK: - Configuration
    @objc
    public func configure(_ configuration: NSDictionary, resolver resolve: RCTPromiseResolveBlock, rejecter reject: RCTPromiseRejectBlock) {
        do {
            // Setup the Liveness's configuration
            let livenessConfiguration = try LivenessConfiguration(configuration: configuration)
            // Setup the native configuration
            try VerifaiLiveness.configure(configuration: livenessConfiguration.nativeConfiguration)

            // Setup the output directory where results will be kept
            if let outputUrl = livenessConfiguration.nativeConfiguration.resultPath {
                try FileManager.default.createDirectory(at: outputUrl,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            }
            resolve(nil)
        } catch {
            reject(ErrorType.configuration, "🚫 Error in configuration", error)
        }
    }

    // MARK: - Liveness Module functions
    @objc
    public func start(_ checks: NSArray, resolver resolve: @escaping RCTPromiseResolveBlock, rejecter reject: @escaping RCTPromiseRejectBlock) {
        // Run Liveness (on the main thread because it's going to be doing UI activities)
        DispatchQueue.main.async {
            // Use React function to get current top view controller
            guard let currentVC = RCTPresentedViewController() else {
                reject(ErrorType.noView, "🚫 No current view controller found", nil)
                return
            }
            do {
                let livenessChecks = try self.processLivenessCheckArguments(checksArray: checks)
                try VerifaiLiveness.start(over: currentVC,
                                          livenessChecks: livenessChecks,
                                          resultBlock: { livenessResult in
                    switch livenessResult {
                    case .success(let result):
                        do {
                            let preparedResult = try self.prepareLivenessResult(result: result)
                            resolve(preparedResult)
                        } catch {
                            reject(ErrorType.resultConversion, "🚫 Result conversion error: \(error)", error)
                        }
                    case .failure(let error):
                        reject(ErrorType.liveness, "🚫 Liveness check failed: \(error)", error)
                    }
                })
            } catch {
                reject(ErrorType.unhandled, "🚫 Unhandled error: \(error)", error)
            }
        }
    }

    /// Convert the argument dict array to a native liveness check array
    /// - Parameter checksArray: The data with the values for the check
    /// - Returns: Native liveness check array
    private func processLivenessCheckArguments(checksArray: NSArray) throws -> [VerifaiLivenessCheck] {
        var livenessChecks: [VerifaiLivenessCheck] = []
        for checkDictionary in checksArray {
            if let check = checkDictionary as? NSDictionary,
                let type = check.value(forKey: "type") as? String {
                switch type {
                case "CloseEyes":
                    livenessChecks.append(try buildClosedEyesCheck(checkData: check))
                case "Tilt":
                    livenessChecks.append(try buildHeadTiltCheck(checkData: check))
                case "Speech":
                    livenessChecks.append(try buildSpeechRecognitionCheck(checkData: check))
                case "FaceMatching":
                    livenessChecks.append(try buildFaceMatchingCheck(checkData: check))
                default:
                    throw RNError.invalidLivenessCheck
                }
            }
        }
        return livenessChecks
    }

    // MARK: - Check builders

    /// Build the eyes closed check from the data coming in from react native
    /// - Parameter checkData: The data with the values for the check
    /// - Returns: A native close eyes check or throws an error if some of the data is invalid
    private func buildClosedEyesCheck(checkData: NSDictionary) throws -> VerifaiCloseEyesLivenessCheck {
        // Close eyes check, find the duration and instruction values
        let duration = checkData.value(forKey: "numberOfSeconds") as? Int ?? 2
        let instruction = checkData.value(forKey: "instruction") as? String ?? nil
        if let eyesCheck = VerifaiCloseEyesLivenessCheck(numberOfSeconds: TimeInterval(duration),
                                                         instruction: instruction) {
            return eyesCheck
        }
        // Invalid data
        throw RNError.invalidLivenessCheck
    }

    /// Build the head tilt check from the data coming in from react native
    /// - Parameter checkData: The data with the values for the check
    /// - Returns: A native head tilt check or throws an error if some of the data is invalid
    private func buildHeadTiltCheck(checkData: NSDictionary) throws -> VerifaiTiltLivenessCheck {
        let faceAngle = checkData.value(forKey: "faceAngle") as? Float ?? 25
        let instruction = checkData.value(forKey: "instruction") as? String ?? "Tilt your head until the green line is reached"
        if let tiltCheck = VerifaiTiltLivenessCheck(faceAngle: faceAngle,
                                                    instruction: instruction) {
            return tiltCheck
        }
        // Invalid data
        throw RNError.invalidLivenessCheck
    }

    /// Build the speech recognition check from the data coming in from react native
    /// - Parameter checkData: The data with the values for the check
    /// - Returns: A native speech recognition check or throws an error if some of the data is invalid
    private func buildSpeechRecognitionCheck(checkData: NSDictionary) throws -> VerifaiSpeechLivenessCheck {
        let speechRequirement = checkData.value(forKey: "speechRequirement") as? String ?? nil
        // The Locale in which speech recognition is performed
        let locale: Locale = Locale(identifier: checkData.value(forKey: "locale") as? String ?? Locale.current.identifier)
        let instruction = checkData.value(forKey: "instruction") as? String ?? nil
        if let speechCheck = VerifaiSpeechLivenessCheck(speechRequirement: speechRequirement,
                                                        locale: locale,
                                                        instruction: instruction) {
            return speechCheck
        }
        // Invalid data
        throw RNError.invalidLivenessCheck
    }

    /// Build the face matching check from the data coming in from react native
    /// - Parameter checkData: The data with the values for the check
    /// - Returns: A native face matching check or throws an error if some of the data is invalid
    private func buildFaceMatchingCheck(checkData: NSDictionary) throws -> VerifaiFaceMatchingLivenessCheck {
        let instruction = checkData.value(forKey: "instruction") as? String ?? nil
        // This can be either the document or NFC image
        if let imageDict = checkData.value(forKey: "documentImage") as? NSDictionary,
          let imageBase64 = imageDict.value(forKey: "base64") as? String,
          let imageData = Data(base64Encoded: imageBase64),
          let image = UIImage(data: imageData) {
              return VerifaiFaceMatchingLivenessCheck(documentImage: image,
                                                      instruction: instruction)
        }
        // Invalid data
        throw RNError.invalidLivenessCheck
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

    // Main queue setup not required
    @objc(requiresMainQueueSetup)
    public static func requiresMainQueueSetup() -> Bool {
        return false
    }

}
