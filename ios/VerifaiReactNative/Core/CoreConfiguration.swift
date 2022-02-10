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
    let globalConfiguration = VerifaiConfiguration()
    
    init(configuration: NSDictionary) throws {
        // Main settings
        if let requireDocumentCopy = configuration.value(forKey: "requireDocumentCopy") as? Bool {
            globalConfiguration.requireDocumentCopy = requireDocumentCopy
        }
        if let requireCroppedImage = configuration.value(forKey: "requireCroppedImage") as? Bool {
            globalConfiguration.requireCroppedImage = requireCroppedImage
        }
        if let enablePostCropping = configuration.value(forKey: "enablePostCropping") as? Bool {
            globalConfiguration.enablePostCropping = enablePostCropping
        }
        if let enableManual = configuration.value(forKey: "enableManual") as? Bool {
            globalConfiguration.enableManual = enableManual
        }
        if let requireMRZContents = configuration.value(forKey: "requireMRZContents") as? Bool {
            globalConfiguration.requireMRZContents = requireMRZContents
        }
        if let readMRZContents = configuration.value(forKey: "readMRZContents") as? Bool {
            globalConfiguration.readMRZContents = readMRZContents
        }
        if let requireNFCWhenAvailable = configuration.value(forKey: "requireNFCWhenAvailable") as? Bool {
            globalConfiguration.requireNFCWhenAvailable = requireNFCWhenAvailable
        }
        if let enableVisualInspection = configuration.value(forKey: "enableVisualInspection") as? Bool {
            globalConfiguration.enableVisualInspection = enableVisualInspection
        }
        if let documentFiltersAutoCreateValidators = configuration.value(
            forKey: "documentFiltersAutoCreateValidators") as? Bool {
            globalConfiguration.documentFiltersAutoCreateValidators = documentFiltersAutoCreateValidators
        }
        if let scanDuration = configuration.value(forKey: "scanDuration") as? Double {
            globalConfiguration.scanDuration = scanDuration
        }
        if let customDismissButtonTitle = configuration.value(forKey: "customDismissButtonTitle") as? String {
            globalConfiguration.customDismissButtonTitle = customDismissButtonTitle
        }
        if let documentFiltersAutoCreateValidators = configuration.value(
            forKey: "documentFiltersAutoCreateValidators") as? Bool {
            globalConfiguration.documentFiltersAutoCreateValidators = documentFiltersAutoCreateValidators
        }
        // Validator configuration
        if let validators = configuration.value(forKey: "validators") as? NSArray {
            globalConfiguration.validators = try processValidators(validatorArray: validators)
        }
        // Document filter configuration
        if let documentFilters = configuration.value(forKey: "documentFilters") as? NSArray {
            globalConfiguration.documentFilters = try processDocumentFilters(documentFilterArray:documentFilters)
        }
        // Instruction screen configuration
        if let instructionConfiguration = configuration.value(forKey: "instructionScreenConfiguration") as? NSDictionary {
            // Whether the instruction screens should be shown (default is yes)
            let showInstructionScreens = instructionConfiguration.value(forKey: "showInstructionScreens") as? Bool ?? true
            // Build the instruction configuration
            globalConfiguration.instructionScreenConfiguration =
            try getInstructionScreenConfiguration(for: instructionConfiguration,
                                                     showInstructionScreens: showInstructionScreens)
        }
        // Scan help configuration
        if let scanHelpConfiguration = configuration.value(forKey: "scanHelpConfiguration") as? NSDictionary {
            // Find the values
            let isScanHelpEnabled = scanHelpConfiguration.value(forKey: "isScanHelpEnabled") as? Bool ?? true
            let customScanHelpScreenInstructions = scanHelpConfiguration.value(
                forKey: "customScanHelpScreenInstructions") as? String ?? ""
            let customScanHelpScreenMp4FileName = scanHelpConfiguration.value(
                forKey: "customScanHelpScreenMp4FileName") as? String ?? ""
            // Create a scan help configuration object
            globalConfiguration.scanHelpConfiguration = VerifaiScanHelpConfiguration(isScanHelpEnabled: isScanHelpEnabled,
                                                                      customScanHelpScreenInstructions:
                        NSAttributedString(string: customScanHelpScreenInstructions),
                                                                      customScanHelpScreenMp4FileName: customScanHelpScreenMp4FileName)
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
        // Find the settings array that holds the settings for each screen
        if let instructionConfigurationArray = instructionConfiguration.value(forKey: "instructionScreens") as? NSArray {
            // Setup screen dictionary holder
            var screenConfigurations: [VerifaiInstructionScreen: VerifaiSingleInstructionScreenConfiguration] = [:]
            // Go trough each screen and set it up
            for dictionary in instructionConfigurationArray {
                if let settings = dictionary as? NSDictionary,
                   let type = settings.value(forKey: "type") as? Int,
                   let instructionScreen = getInstructionScreen(in: settings) {
                    // Create the screen values
                    switch type {
                    case 0:
                        // Default values
                        screenConfigurations[instructionScreen] = .defaultMode
                    case 1:
                        // Native based configuration screen
                        screenConfigurations[instructionScreen] = try nativeScreenValues(in: settings)
                    case 2:
                        // Web based instruction values
                        screenConfigurations[instructionScreen] = try getWebScreenValues(in: settings)
                    case 3:
                        // Hide the specific instruction screen
                        screenConfigurations[instructionScreen] = .hidden
                    default:
                        // Illegal argument, stop the operation
                        throw RNError.invalidValuesSupplied
                    }
                }
            }
            return try VerifaiInstructionScreenConfiguration(showInstructionScreens: showInstructionScreens,
                                                             instructionScreens: screenConfigurations)
        }
        throw RNError.invalidValuesSupplied
    }
    
    /// Get the Core instruction screen enum value
    /// - Parameter settings: The settings dictionary
    /// - Returns: the enum matched or nil
    private func getInstructionScreen(in settings: NSDictionary) -> VerifaiInstructionScreen? {
        if let screen = settings.value(forKey: "screen") as? Int {
            switch screen {
            case 0: return .mrzPresentFlowInstruction
            case 1: return .mrzScanFlowInstruction
            case 3: return .documentChooserTabBarInstruction
            default:
                // Illegal value
                return nil
            }
        }
        // Illegal value
        return nil
    }
    
    /// Get the instruction screen values for a native instruction screen
    /// - Parameter settings: The settings dictionary that was passed
    /// - Returns: A screen configuration for a native instruction screen
    private func nativeScreenValues(in settings: NSDictionary) throws -> VerifaiSingleInstructionScreenConfiguration {
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
    private func getWebScreenValues(in settings: NSDictionary) throws -> VerifaiSingleInstructionScreenConfiguration {
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
                guard let type = validator.value(forKey: "type") as? Int else {
                    throw RNError.invalidValidator
                }
                switch type {
                case 0:
                    // VerifaiDocumentCountryWhitelistValidator
                    let countryList = validator.value(forKey: "countryList") as? [String] ?? []
                    validatorHolder.append(VerifaiDocumentCountryWhiteListValidator(countries: countryList))
                case 1:
                    // VerifaiDocumentCountryBlackListValidator
                    let countryList = validator.value(forKey: "countryList") as? [String] ?? []
                    validatorHolder.append(VerifaiDocumentCountryBlackListValidator(countries: countryList))
                case 2:
                    // VerifaiDocumentHasMrzValidator
                    validatorHolder.append(VerifaiDocumentHasMrzValidator())
                case 3:
                    // VerifaiDocumentTypesValidator
                    let validDocumentTypes = validator.value(forKey: "validDocumentTypes") as? [Int] ?? []
                    let nativeValidTypes = try getNativeDocumentTypes(in: validDocumentTypes)
                    validatorHolder.append(VerifaiDocumentTypesValidator(validDocumentTypes: nativeValidTypes))
                case 4:
                    // VerifaiMrzAvailableValidator
                    validatorHolder.append(VerifaiMrzAvailableValidator())
                case 5:
                    // VerifaiNFCKeyWhenAvailableValidator
                    validatorHolder.append(VerifaiNFCKeyWhenAvailableValidator())
                default:
                    throw RNError.invalidValidator
                }
            }
        }
        return validatorHolder
    }
    
    /// Process an array of string based document types coming from react native
    /// - Parameter validDocumentTypes: An array of ints representing the document types
    /// - Returns: An array of native document types, or an invalid validator error
    private func getNativeDocumentTypes(in validDocumentTypes: [Int]) throws -> [VerifaiDocumentType] {
        var typesHolder: [VerifaiDocumentType] = []
        for validType in validDocumentTypes {
            switch validType {
            case 0:
                typesHolder.append(.idCard)
            case 1:
                typesHolder.append(.driversLicence)
            case 2:
                typesHolder.append(.passport)
            case 3:
                typesHolder.append(.refugee)
            case 4:
                typesHolder.append(.emergencyPassport)
            case 5:
                typesHolder.append(.residencePermitTypeI)
            case 6:
                typesHolder.append(.residencePermitTypeII)
            case 7:
                typesHolder.append(.visa)
            case 8:
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
                guard let type = documentFilter.value(forKey: "type") as? Int else {
                    throw RNError.invalidDocumentFilter
                }
                switch type {
                case 0:
                    // VerifaiDocumentTypeWhiteListFilter
                    let validDocumentTypes = documentFilter.value(forKey: "validDocumentTypes") as? [Int] ?? []
                    let nativeValidTypes = try getNativeDocumentTypes(in: validDocumentTypes)
                    let documentTypeFilter = VerifaiDocumentTypeWhiteListFilter(validDocumentTypes: nativeValidTypes)
                    documentFilterHolder.append(documentTypeFilter)
                case 1:
                    // VerifaiDocumentWhiteListFilter
                    let countryCodes = documentFilter.value(forKey: "countryCodes") as? [String] ?? []
                    documentFilterHolder.append(VerifaiDocumentWhiteListFilter(countryCodes: countryCodes))
                case 2:
                    // VerifaiDocumentBlackListFilter
                    let countryCodes = documentFilter.value(forKey: "countryCodes") as? [String] ?? []
                    documentFilterHolder.append(VerifaiDocumentBlackListFilter(countryCodes: countryCodes))
                default:
                    throw RNError.invalidDocumentFilter
                }
            }
        }
        return documentFilterHolder
    }
}
