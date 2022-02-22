//
//  LivenessConfiguration.swift
//  verifai-react-native
//
//  Created by Richard Chirino on 01/02/2022.
//

import Foundation
import VerifaiLivenessKit

struct LivenessConfiguration {
    // Properties
    var requirements: [VerifaiLivenessCheck]? = nil
    var resultOutputDirectory: URL? = nil
    var showDismissButton: Bool = true
    var customDismissButtonTitle: String? = nil
    
    init(configuration: NSDictionary) throws {
        // Where the check videos should be stored
        if let resultOutputDirectory = configuration.value(forKey: "resultOutputDirectory") as? String {
            self.resultOutputDirectory = URL(fileURLWithPath: resultOutputDirectory)
        }
        // Whether the dismiss button should be shown
        if let showDismissButton = configuration.value(forKey: "showDismissButton") as? Bool {
            self.showDismissButton = showDismissButton
        }
        // Custom dismiss button title string
        if let customDismissButtonTitle = configuration.value(forKey: "customDismissButtonTitle") as? String {
            self.customDismissButtonTitle = customDismissButtonTitle
        }
        // Liveness checks
        if let checksArray = configuration.value(forKey: "checks") as? NSArray {
            var livenessChecks: [VerifaiLivenessCheck] = []
            for checkDictionary in checksArray {
                if let check = checkDictionary as? NSDictionary,
                    let type = check.value(forKey: "check") as? Int {
                    // Declare the native type based on the check
                    switch type {
                    case 0:
                        // Closed eyes check
                        livenessChecks.append(try buildClosedEyesCheck(checkData: check))
                    case 1:
                        // Tilt head check
                        livenessChecks.append(try buildHeadTiltCheck(checkData: check))
                    case 2:
                        // Speech recognition check
                        livenessChecks.append(try buildSpeechRecognitionCheck(checkData: check))
                    case 3:
                        // Face matching check
                        livenessChecks.append(try buildFaceMatchingCheck(checkData: check))
                    default:
                        throw RNError.invalidLivenessCheck
                    }
                }
            }
            self.requirements = livenessChecks
        }
    }
    
    // MARK: - Check builders
    
    /// Build the eyes closed check from the data coming in from react native
    /// - Parameter checkData: The data with the values for the check
    /// - Returns: A native close eyes check or throws an error if some of the data is invalid
    private func buildClosedEyesCheck(checkData: NSDictionary) throws -> VerifaiEyesLivenessCheck {
        // Close eyes check, find the duration and instruction values
        let duration = checkData.value(forKey: "numberOfSeconds") as? Int ?? 2
        let instruction = checkData.value(forKey: "instruction") as? String ?? nil
        if let eyesCheck = VerifaiEyesLivenessCheck(duration: TimeInterval(duration),
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
        let faceAngle = checkData.value(forKey: "faceAngleRequirement") as? Float ?? 25
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
        let imageSource = checkData.value(forKey: "imageSource") as? Int ?? 0
        let instruction = checkData.value(forKey: "instruction") as? String ?? nil
        // Determine if we need to use the document or the NFC image
        switch imageSource {
        case 0:
            // Ensure there's a result with a front image
            guard let currentResult = VerifaiResultSingleton.shared.currentResult,
                  let frontImage = currentResult.frontImage else {
                      throw RNError.invalidLivenessCheck
            }
            let check = VerifaiFaceMatchingLivenessCheck(documentImage: frontImage,
                                                         instruction: instruction)
            return check
        case 1:
            // Ensure there's an NFC image
            guard let nfcImage = VerifaiResultSingleton.shared.nfcImage else {
                throw RNError.invalidLivenessCheck
            }
            let check = VerifaiFaceMatchingLivenessCheck(documentImage: nfcImage,
                                                         instruction: instruction)
            return check
        default:
            throw RNError.invalidLivenessCheck
        }
    }
}
