//
//  VerifaiNFCReactNativeResult.swift
//  verifai-react-native
//
//  Created by Richard Chirino on 25/01/2022.
//

import Foundation
import VerifaiCommonsKit
import VerifaiNFCKit

class VerifaiNFCReactNativeResult: Codable {
    
    var originality: Bool
    var authenticity: Bool
    var confidentiality: Bool
    var bacStatus: VerifaiBacStatus
    var paceStatus: VerifaiPACEStatus
    var activeAuthenticationStatus: VerifaiActiveAuthStatus
    var chipAuthenticationStatus: VerifaiChipAuthStatus
    var isMrzMatch: Bool
    var mrzData: VerifaiMRZModel?
    var faceImage: VerifaiReactNativeImageResult?
    var areDataChecksumsValid: Bool
    var isDocumentSignatureCorrect: Bool
    var isDocumentCertificateValid: Bool
    var countrySignatureStatus: VerifaiRootCertificateStatus
    var documentSpecificData: VerifaiNFCDocumentSpecificData?
    var documentNfcIdentifier: VerifaiApplicationSelectionType
    
    init(nfcResult: VerifaiLocalNFCResult) {
        // Define react native user image
        if let image = nfcResult.faceImage {
            faceImage = VerifaiReactNativeImageResult(base64: image.pngData()?.base64EncodedString() ?? "",
                                                      width: image.size.width,
                                                      height: image.size.height)
        }
        // Set the rest of the values to be equal to the normal result
        self.authenticity = nfcResult.authenticity
        self.confidentiality = nfcResult.confidentiality
        self.originality = nfcResult.originality
        self.isMrzMatch = nfcResult.isMRZMatch
        self.areDataChecksumsValid = nfcResult.areDataChecksumsValid
        self.isDocumentSignatureCorrect = nfcResult.isDocumentSignatureCorrect
        self.isDocumentCertificateValid = nfcResult.isDocumentCertificateValid
        self.countrySignatureStatus = nfcResult.countrySignatureStatus
        self.bacStatus = nfcResult.bacStatus
        self.paceStatus = nfcResult.paceStatus
        self.activeAuthenticationStatus = nfcResult.activeAuthenticationStatus
        self.chipAuthenticationStatus = nfcResult.chipAuthenticationStatus
        self.mrzData = nfcResult.mrzData
        self.documentSpecificData = nfcResult.documentSpecificData
        self.documentNfcIdentifier = nfcResult.documentNfcIdentifier
    }
}
