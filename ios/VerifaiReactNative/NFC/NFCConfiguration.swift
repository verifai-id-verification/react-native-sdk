//
//  NFCConfiguration.swift
//  verifai-react-native
//
//  Created by Richard Chirino on 28/01/2022.
//

import Foundation
import VerifaiNFCKit

struct NFCConfiguration {
    var retrieveImage: Bool = true
    var showDismissButton: Bool = true
    var customDismissButtonTitle: String? = nil
    var scanHelpConfiguration: String? = nil
    var instructionScreenConfiguration: VerifaiNFCInstructionScreenConfiguration?
    
    init(configuration: NSDictionary) throws {
        // Whether the image of the passport should be fetched
        if let retrieveImage = configuration.value(forKey: "retrieveImage") as? Bool {
            self.retrieveImage = retrieveImage
        }
        // Whether the dismiss button should be shown
        if let showDismissButton = configuration.value(forKey: "showDismissButton") as? Bool {
            self.showDismissButton = showDismissButton
        }
        // Custom dismiss button title string
        if let customDismissButtonTitle = configuration.value(forKey: "customDismissButtonTitle") as? String {
            self.customDismissButtonTitle = customDismissButtonTitle
        }
        // Instruction screen configuration
        if let instructionConfiguration = configuration.value(forKey: "instructionScreenConfiguration") as? NSDictionary {
            // Whether the instruction screens should be shown (default is yes)
            let showInstructionScreens = instructionConfiguration.value(forKey: "showInstructionScreens") as? Bool ?? true
            // Build the instruction configuration
            self.instructionScreenConfiguration =
            try getInstructionScreenConfiguration(for: instructionConfiguration,
                                                     showInstructionScreens: showInstructionScreens)
        }
    }
    
    /// Process the instruction screen provided into something the Verifai SDK can understand
    /// - Parameters:
    ///   - instructionConfiguration: The instruction configuration provided by the react native app
    ///   - showInstructionScreens: Flag that defines whether all the instruction screens should be shown.
    ///   This values also comes from the react native side
    /// - Returns: The instruction screen configuration or an error if the configuration contains invalid arguments
    private func getInstructionScreenConfiguration(for instructionConfiguration: NSDictionary,
                                                   showInstructionScreens: Bool) throws -> VerifaiNFCInstructionScreenConfiguration {
        // Find the settings array that holds the settings for each screen
        if let instructionConfigurationArray = instructionConfiguration.value(forKey: "instructionScreens") as? NSArray {
            // Setup screen dictionary holder
            var screenConfigurations: [VerifaiNFCInstructionScreen: VerifaiNFCSingleInstructionScreenConfiguration] = [:]
            // Go trough each screen and set it up
            for dictionary in instructionConfigurationArray {
                if let settings = dictionary as? NSDictionary,
                   let type = settings.value(forKey: "type") as? String,
                   let instructionScreen = getInstructionScreen(in: settings) {
                    // Create the screen values
                    switch type {
                    case "customWeb":
                        // Web based instruction values
                        screenConfigurations[instructionScreen] = try webScreenValues(in: settings)
                    case "customLocal":
                        // Native based configuration screen
                        screenConfigurations[instructionScreen] = try nativeScreenValues(in: settings)
                    case "defaultMode":
                        // Default values
                        screenConfigurations[instructionScreen] = .defaultMode
                    case "hidden":
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
        let mp4FileName = settings.value(forKey: "mp4FileName") as? String ?? ""
        let instruction = settings.value(forKey: "instruction") as? String ?? ""
        let continueButtonLabel = settings.value(forKey: "continueButtonLabel") as? String ?? ""
        // Build the screen values object
        let screenValues = try VerifaiInstructionScreenValues(title: title,
                                                              header: header,
                                                              mp4FileName: mp4FileName,
                                                              instruction: NSAttributedString(string: instruction),
                                                              continueButtonLabel: continueButtonLabel)
        // We can return the instruction screen object
        return .customLocal(screenValues: screenValues)
    }
    
    /// Get the instruction screen values for a web based instruction screen
    /// - Parameter settings: The settings dictionary that was passed
    /// - Returns: A screen configuration for a web based instruction screen
    private func webScreenValues(in settings: NSDictionary) throws -> VerifaiNFCSingleInstructionScreenConfiguration {
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
        return .customWeb(screenValues: webValues)
    }
    
    /// Get the NFC instruction screen enum value
    /// - Parameter settings: The settings dictionary
    /// - Returns: the enum matched or nil
    private func getInstructionScreen(in settings: NSDictionary) -> VerifaiNFCInstructionScreen? {
        if let screen = settings.value(forKey: "screen") as? String {
            switch screen {
            case "nfcScanFlowInstruction":
                return .nfcScanFlowInstruction
            default:
                // Illegal value
                return nil
            }
        }
        // Illegal value
        return nil
    }
    
    public enum RNError: Error {
        case invalidUrl
        case invalidValuesSupplied
    }
}
