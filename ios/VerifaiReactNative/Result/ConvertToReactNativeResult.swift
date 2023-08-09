//
//  ConvertToReactNativeResult.swift
//  VerifaiReactNative
//
//  Created by Jeroen Oomkes on 16/06/2023.
//

import Foundation
import VerifaiNFCKit
import VerifaiCommonsKit

// Create a shared JSONEncoder instance
var encoder: JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    return encoder
}

/// Prepare Core result into something react native can understand
/// - Parameter result: The result coming from the core
func prepareCoreResult(result: VerifaiLocalCoreResult) throws -> NSDictionary {
    let data = try encoder.encode(VerifaiReactNativeResult(result: result))
    guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                            options: .fragmentsAllowed) as? [String: Any] else  {
        throw RNError.unableToCreateResult
    }
    return NSDictionary(dictionary: dictionary)
}

/// Prepare Core API result into something react native can understand
/// - Parameter result: The result coming from the API Core Scan
func prepareAPICoreResult(coreAPIResult: VerifaiCoreResult) throws -> NSDictionary {
    let data = try encoder.encode(VerifaiAPICoreResult(coreAPIResult: coreAPIResult))
    guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                            options: .fragmentsAllowed) as? [String: Any] else  {
        throw RNError.unableToCreateResult
    }
    return NSDictionary(dictionary: dictionary)
}

/// Prepare NFC result into something react native can understand
/// - Parameter result: The result coming from the NFC module
func prepareNFCResult(result: VerifaiLocalCombinedResult) throws -> NSDictionary {
    var nfcData: VerifaiNFCReactNativeResult? = nil
    if let data = result.nfc {
        nfcData = VerifaiNFCReactNativeResult(nfcResult: data)
    }
    let combinedData = VerifaiLocalCombinedReactNativeResult(core: VerifaiReactNativeResult(result: result.core),
                                                             nfc: nfcData,
                                                             error: result.nfcError)
    let data = try encoder.encode(combinedData)
    guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                            options: .fragmentsAllowed) as? [String: Any] else  {
        throw RNError.unableToCreateResult
    }
    return NSDictionary(dictionary: dictionary)
}

/// Prepare NFC API result into something react native can understand
/// - Parameter result: The result coming from the API NFC Scan
func prepareAPINFCResult(nfcAPIResult: VerifaiNFCResult) throws -> NSDictionary {
    let data = try encoder.encode(VerifaiAPINFCResult(nfcAPIResult: nfcAPIResult))
    guard let dictionary = try JSONSerialization.jsonObject(with: data,
                                                            options: .fragmentsAllowed) as? [String: Any] else  {
        throw RNError.unableToCreateResult
    }
    return NSDictionary(dictionary: dictionary)
}
