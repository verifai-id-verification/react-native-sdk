//
//  CoreConfiguration.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 03/02/2022.
//

import Foundation
import VerifaiKit
import VerifaiCommonsKit

struct CoreConfiguration {
    // Properties
    var nativeConfiguration = VerifaiCoreConfiguration()

    init(configuration: NSDictionary) throws {
        // Main settings
        if let requireDocumentCopy = configuration.value(forKey: "requireDocumentCopy") as? Bool {
            nativeConfiguration.requireDocumentCopy = requireDocumentCopy
        }
        if let enableCropping = configuration.value(forKey: "enableCropping") as? Bool {
            nativeConfiguration.enableCropping = enableCropping
        }
        if let enableManualFlow = configuration.value(forKey: "enableManualFlow") as? Bool {
            nativeConfiguration.enableManualFlow = enableManualFlow
        }
        if let requireMrz = configuration.value(forKey: "requireMrz") as? Bool {
            nativeConfiguration.requireMrz = requireMrz
        }
        if let requireNFCWhenAvailable = configuration.value(forKey: "requireNfcWhenAvailable") as? Bool {
            nativeConfiguration.requireNFCWhenAvailable = requireNFCWhenAvailable
        }
        if let validators = configuration.value(forKey: "validators") as? NSArray {
            nativeConfiguration.validators = try processValidators(validatorArray: validators)
        }
        if let documentFilters = configuration.value(forKey: "documentFilters") as? NSArray {
            nativeConfiguration.documentFilters = try processDocumentFilters(documentFilterArray:documentFilters)
        }
        if let autoCreateValidators = configuration.value(forKey: "autoCreateValidators") as? Bool {
            nativeConfiguration.autoCreateValidators = autoCreateValidators
        }
        if let scanHelpConfiguration = configuration.value(forKey: "scanHelpConfiguration") as? NSDictionary {
            // Find the values
            let isScanHelpEnabled = scanHelpConfiguration.value(forKey: "isScanHelpEnabled") as? Bool ?? true
            let customScanHelpScreenInstructions = scanHelpConfiguration.value(
                forKey: "customScanHelpScreenInstructions") as? String ?? ""
            let customScanHelpScreenMp4VideoResource = scanHelpConfiguration.value(
                forKey: "customScanHelpScreenMediaResource") as? String ?? ""
            // Create a scan help configuration object
            nativeConfiguration.scanHelpConfiguration = VerifaiScanHelpConfiguration(isScanHelpEnabled: isScanHelpEnabled,
                                                                                     customScanHelpScreenInstructions: NSAttributedString(string: customScanHelpScreenInstructions),
                                                                                     customScanHelpScreenMp4VideoResource: customScanHelpScreenMp4VideoResource)
        }
        if let requireCroppedImage = configuration.value(forKey: "requireCroppedImage") as? Bool {
            nativeConfiguration.requireCroppedImage = requireCroppedImage
        }
        if let instructionConfiguration = configuration.value(forKey: "instructionScreenConfiguration") as? NSDictionary {
            if instructionConfiguration.count > 0 {
                // Whether the instruction screens should be shown (default is yes)
                let showInstructionScreens = instructionConfiguration.value(forKey: "showInstructionScreens") as? Bool ?? true
                // Build the instruction configuration
                nativeConfiguration.instructionScreenConfiguration =
                    try getInstructionScreenConfiguration(for: instructionConfiguration,
                                                          showInstructionScreens: showInstructionScreens)
            }
        }
        if let enableVisualInspection = configuration.value(forKey: "enableVisualInspection") as? Bool {
            nativeConfiguration.enableVisualInspection = enableVisualInspection
        }
        if let customDismissButtonTitle = configuration.value(forKey: "customDismissButtonTitle") as? String {
            nativeConfiguration.customDismissButtonTitle = customDismissButtonTitle
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
                                                   showInstructionScreens: Bool) throws -> VerifaiInstructionScreenConfiguration {
        var screenConfigurations: [VerifaiInstructionScreen: VerifaiSingleInstructionScreenConfiguration] = [:]
      
        // Find the settings array that holds the settings for each screen
        if let instructionConfigurationDict = instructionConfiguration.value(forKey: "instructionScreens") as? NSDictionary {
            // Setup screen dictionary holder
            // Go trough each screen and set it up
            for (key, value) in instructionConfigurationDict {
                if let settings =  value as? NSDictionary,
                   let type = settings.value(forKey: "type") as? String,
                   let id = key as? String,
                   let instructionScreen = getInstructionScreen(instructionScreenId: id) {
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
                throw RNError.invalidValuesSupplied
            }
        }
        return try VerifaiInstructionScreenConfiguration(showInstructionScreens: showInstructionScreens,
                                                         instructionScreens: screenConfigurations)
    }

    /// Get the Core instruction screen enum value
    /// - Parameter settings: The settings dictionary
    /// - Returns: the enum matched or nil
    private func getInstructionScreen(instructionScreenId: String) -> VerifaiInstructionScreen? {
        switch instructionScreenId {
        case "MrzPresentFlowInstruction": return .mrzPresentFlowInstruction
        case "MrzScanFlowInstruction": return .mrzScanFlowInstruction
        case "DocumentPickerInstruction": return .documentPickerInstruction
        default:
            // Illegal value
            return nil
        }
    }

    /// Get the instruction screen values for a native instruction screen
    /// - Parameter settings: The settings dictionary that was passed
    /// - Returns: A screen configuration for a native instruction screen
    private func nativeScreenValues(in settings: NSDictionary) throws -> VerifaiSingleInstructionScreenConfiguration {
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
    private func getWebScreenValues(in arguments: NSDictionary) throws -> VerifaiSingleInstructionScreenConfiguration {
        // Find the values
        let title = arguments.value(forKey: "title") as? String ?? ""
        let urlString = arguments.value(forKey: "url") as? String ?? ""
        let continueButtonLabel = arguments.value(forKey: "continueButtonLabel") as? String ?? ""
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

    // MARK: - Validators

    /// Process validators sent via react native in a string based dictionary / array system
    /// - Parameter validatorArray: The array with values coming from react native
    /// - Returns: An array of native validators
    private func processValidators(validatorArray: NSArray) throws -> [VerifaiValidator] {
        var validatorHolder: [VerifaiValidator] = []
        // Go trough the validator list and convert them to their native counterparts
        for i in validatorArray {
            if let validator = i as? NSDictionary {
                // Get the type of validator
                guard let type = validator.value(forKey: "type") as? String else {
                    throw RNError.invalidValidator
                }
                switch type {
                case "DocumentCountryAllowlistValidator":
                    let countryList = validator.value(forKey: "countryCodes") as? [String] ?? []
                    validatorHolder.append(VerifaiDocumentCountryAllowlistValidator(countries: countryList))
                case "DocumentCountryBlocklistValidator":
                    let countryList = validator.value(forKey: "countryCodes") as? [String] ?? []
                    validatorHolder.append(VerifaiDocumentCountryBlocklistValidator(countries: countryList))
                case "DocumentHasMrzValidator":
                    validatorHolder.append(VerifaiDocumentHasMrzValidator())
                case "DocumentTypesValidator":
                    let documentTypes = validator.value(forKey: "documentTypes") as? [String] ?? []
                    let nativeValidTypes = try getNativeDocumentTypes(in: documentTypes)
                    validatorHolder.append(VerifaiDocumentTypesValidator(validDocumentTypes: nativeValidTypes))
                case "MrzAvailableValidator":
                    validatorHolder.append(VerifaiMrzAvailableValidator())
                case "NfcKeyWhenAvailableValidator":
                    validatorHolder.append(VerifaiNFCKeyWhenAvailableValidator())
                default:
                    throw RNError.invalidValidator
                }
            }
        }
        return validatorHolder
    }

    /// Process an array of int (enum) based document types coming from react native
    /// - Parameter validDocumentTypes: An array of ints representing the document types
    /// - Returns: An array of native document types, or an invalid validator error
    private func getNativeDocumentTypes(in validDocumentTypes: [String]) throws -> [VerifaiDocumentType] {
        var typesHolder: [VerifaiDocumentType] = []
        for validType in validDocumentTypes {
            switch validType {
            case "IdentityCard":
                typesHolder.append(.idCard)
            case "DrivingLicense":
                typesHolder.append(.driversLicense)
            case "Passport":
                typesHolder.append(.passport)
            case "RefugeeTravelDocument":
                typesHolder.append(.refugee)
            case "EmergencyPassport":
                typesHolder.append(.emergencyPassport)
            case "ResidencePermitTypeI":
                typesHolder.append(.residencePermitTypeI)
            case "ResidencePermitTypeII":
                typesHolder.append(.residencePermitTypeII)
            case "Visa":
                typesHolder.append(.visa)
            case "Unknown":
                typesHolder.append(.unknown)
            default:
                throw RNError.invalidValidator
            }
        }
        return typesHolder
    }

    // MARK: Document Filters

    /// Process document filters dictionary coming from the react native side into
    /// something the native SDK can understand
    /// - Parameter documentFilterArray: The array with values coming from the react native side
    /// - Returns: A native Verifai document filter array that can be set in the native configuration
    private func processDocumentFilters(documentFilterArray: NSArray) throws -> [VerifaiDocumentFilter] {
        var documentFilterHolder: [VerifaiDocumentFilter] = []
        // Go trough the validator list and convert them to their native counterparts
        for i in documentFilterArray {
            if let documentFilter = i as? NSDictionary {
                guard let type = documentFilter.value(forKey: "type") as? String else {
                    throw RNError.invalidDocumentFilter
                }
                switch type {
                case "DocumentTypeAllowlistFilter":
                    let validDocumentTypes = documentFilter.value(forKey: "documentTypes") as? [String] ?? []
                    let nativeValidTypes = try getNativeDocumentTypes(in: validDocumentTypes)
                    let documentTypeFilter = VerifaiDocumentTypeAllowlistFilter(validDocumentTypes: nativeValidTypes)
                    documentFilterHolder.append(documentTypeFilter)
                case "DocumentAllowlistFilter":
                    let countryList = documentFilter.value(forKey: "countryCodes") as? [String] ?? []
                    documentFilterHolder.append(VerifaiDocumentAllowlistFilter(countryCodes: countryList))
                case "DocumentBlocklistFilter":
                    let countryList = documentFilter.value(forKey: "countryCodes") as? [String] ?? []
                    documentFilterHolder.append(VerifaiDocumentBlocklistFilter(countryCodes: countryList))
                default:
                    throw RNError.invalidDocumentFilter
                }
            }
        }
        return documentFilterHolder
    }
}
