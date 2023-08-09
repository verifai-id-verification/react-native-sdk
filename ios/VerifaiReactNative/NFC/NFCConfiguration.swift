//
//  NFCConfiguration.swift
//  verifai-react-native
//
//  Created by Richard Chirino on 28/01/2022.
//

import Foundation
import VerifaiNFCKit

struct NFCConfiguration {
    var nativeConfiguration = VerifaiNFCConfiguration()

    init(configuration: NSDictionary) throws {
        // Whether the image of the passport should be fetched
        if let retrieveImage = configuration.value(forKey: "retrieveFaceImage") as? Bool {
            self.nativeConfiguration.retrieveFaceImage = retrieveImage
        }

        // Instruction screen configuration
        if let instructionConfiguration = configuration.value(forKey: "instructionScreenConfiguration") as? NSDictionary {
            if instructionConfiguration.count > 0 {
                // Whether the instruction screens should be shown (default is yes)
                let showInstructionScreens = instructionConfiguration.value(forKey: "showInstructionScreens") as? Bool ?? true
                // Build the instruction configuration
                self.nativeConfiguration.instructionScreenConfiguration =
                    try getInstructionScreenConfiguration(for: instructionConfiguration,
                                                          showInstructionScreens: showInstructionScreens)
            }
        }

      // Scan help configuration
        if let scanHelpConfiguration = configuration.value(forKey: "scanHelpConfiguration") as? NSDictionary {
            // Find the values
            let isScanHelpEnabled = scanHelpConfiguration.value(forKey: "isScanHelpEnabled") as? Bool ?? true
            let customScanHelpScreenInstructions = scanHelpConfiguration.value(
                forKey: "customScanHelpScreenInstructions") as? String ?? ""
            let customScanHelpScreenMp4VideoResource = scanHelpConfiguration.value(
                forKey: "customScanHelpScreenMediaResource") as? String ?? ""
            // Create a scan help configuration object
            self.nativeConfiguration.scanHelpConfiguration = VerifaiScanHelpConfiguration(isScanHelpEnabled: isScanHelpEnabled,
                                                                                       customScanHelpScreenInstructions: NSAttributedString(string: customScanHelpScreenInstructions),
                                                                                       customScanHelpScreenMp4VideoResource: customScanHelpScreenMp4VideoResource)
        }
    }

    // MARK: - Instruction screen
    /// Process the instruction screen provided into something the Verifai SDK can understand
    /// - Parameters:
    ///   - instructionConfiguration: The instruction configuration provided by the react native app
    ///   - showInstructionScreens: Flag that defines whether all the instruction screens should be shown.
    ///   This values also comes from the react native side
    /// - Returns: The instruction screen configuration or an error if the configuration contains invalid arguments
    private func getInstructionScreenConfiguration(for instructionConfiguration: NSDictionary,
                                                   showInstructionScreens: Bool) throws -> VerifaiNFCInstructionScreenConfiguration {
        // Find the settings array that holds the settings for each screen
        if let instructionConfigurationDict = instructionConfiguration.value(forKey: "instructionScreens") as? NSDictionary {
            // Setup screen dictionary holder
            var screenConfigurations: [VerifaiNFCInstructionScreen: VerifaiNFCSingleInstructionScreenConfiguration] = [:]
            // Go trough each screen and set it up
            for (key, value) in instructionConfigurationDict {
                if let settings = value as? NSDictionary,
                   let type = settings.value(forKey: "type") as? String,
                   let id = key as? String,
                   let instructionScreen = getInstructionScreen(in: id) {
                    // Create the screen values
                    switch type {
                    case "DefaultScreen":
                        // Default values
                        screenConfigurations[instructionScreen] = .defaultScreen
                    case "Custom":
                        // Native based configuration screen
                        if let arguments = settings.value(forKey: "arguments") as? NSDictionary {
                            screenConfigurations[instructionScreen] = try nativeScreenValues(in: arguments)
                        }
                    case "Web":
                        // Web based instruction values
                        if let arguments = settings.value(forKey: "arguments") as? NSDictionary {
                            screenConfigurations[instructionScreen] = try getWebScreenValues(in: arguments)
                        }
                    case "Hidden":
                        // Hide the specific instruction screen
                        screenConfigurations[instructionScreen] = .hidden
                    default:
                        // Illegal argument, stop the operation
                        throw RNError.invalidValuesSupplied
                    }
                }
            }
            return try VerifaiNFCInstructionScreenConfiguration(showInstructionScreens: showInstructionScreens,
                                                                instructionScreens: screenConfigurations)
        }
        throw RNError.invalidValuesSupplied
    }

    /// Get the instruction screen values for a native instruction screen
    /// - Parameter settings: The settings dictionary that was passed
    /// - Returns: A screen configuration for a native instruction screen
    private func nativeScreenValues(in settings: NSDictionary) throws -> VerifaiNFCSingleInstructionScreenConfiguration {
        // Find the values
        let title = settings.value(forKey: "title") as? String ?? ""
        let header = settings.value(forKey: "header") as? String ?? ""
        let mp4VideoResource = settings.value(forKey: "mediaResource") as? String ?? ""
        let instruction = settings.value(forKey: "instruction") as? String ?? ""
        let continueButtonLabel = settings.value(forKey: "continueButtonLabel") as? String ?? ""
        // Build the screen values object
        let screenValues = try VerifaiInstructionScreenValues(title: title,
                                                              header: header,
                                                              mediaResource: mp4VideoResource,
                                                              instruction: NSAttributedString(string: instruction),
                                                              continueButtonLabel: continueButtonLabel)
        // We can return the instruction screen object
        return .custom(screenValues: screenValues)
    }

    /// Get the instruction screen values for a web based instruction screen
    /// - Parameter settings: The settings dictionary that was passed
    /// - Returns: A screen configuration for a web based instruction screen
    private func getWebScreenValues(in settings: NSDictionary) throws -> VerifaiNFCSingleInstructionScreenConfiguration {
        // Find the values
        let title = settings.value(forKey: "title") as? String ?? ""
        let urlString = settings.value(forKey: "url") as? String ?? ""
        let continueButtonLabel = settings.value(forKey: "continueButtonLabel") as? String ?? ""
        // Ensure the url is valid
        guard let url = URL(string: urlString) else {
            throw RNError.invalidUrl
        }
        let webValues = try VerifaiWebInstructionScreenValues(title: title,
                                                              url: url,
                                                              continueButtonLabel: continueButtonLabel,
                                                              loader: .webView)
        return .web(screenValues: webValues)
    }

    /// Get the NFC instruction screen enum value
    /// - Parameter settings: The settings dictionary
    /// - Returns: the enum matched or nil
    private func getInstructionScreen(in instructionScreenId: String) -> VerifaiNFCInstructionScreen? {
        switch instructionScreenId {
        case "NfcScanFlowInstruction":
            return .nfcScanFlowInstruction
        default:
            // Illegal value
            return nil
        }
    }
}
