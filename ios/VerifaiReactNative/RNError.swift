//
//  RNError.swift
//  verifai-react-native
//
//  Created by Richard Chirino on 01/02/2022.
//

import Foundation

// MARK: - Errors
public enum RNError: Error {
    case unableToCreateResult
    case invalidUrl
    case invalidValuesSupplied
    case invalidLivenessCheck
    case invalidValidator
    case invalidDocumentFilter
}
