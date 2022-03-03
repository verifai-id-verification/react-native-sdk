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
    
    var authenticity: Bool
    var confidentiality: Bool
    var originality: Bool
    var mrzMatch: Bool
    var dataGroupHashesValid: Bool
    var bacSuccess: Bool
    var activeAuthenticationSuccess: Bool
    var chipAuthenticationSuccess: Bool
    var documentSignatureCorrect: Bool
    var documentCertificateValid: Bool
    var signingCertificateMatchesWithParent: VerifaiRootCertificateStatus
    var scanCompleted: Bool
    var bacStatus: VerifaiBacStatus
    var activeAuthenticationStatus: VerifaiActiveAuthStatus
    var chipAuthenticationStatus: VerifaiChipAuthStatus
    var photo: VerifaiReactNativeImageResult?
    var mrzData: VerifaiMRZModel?
    var dataGroups: [UInt8 : Data]?
    var dataGroupHashes: [UInt8 : Data]?
    var documentSpecificData: VerifaiNFCDocumentSpecificData?
    var documentCertificate: String?
    var type: VerifaiApplicationSelectionType
    var sodHashes: [UInt8 : Data]?
    var sodData: Data?
    var aaDigestAlgorithm: String?
    var chipAuthenticationOid: String?
    var signingCertificate: String?
    
    
    init(nfcResult: VerifaiNFCResult) {
        // Define react native user image
        if let image = nfcResult.photo {
            photo = VerifaiReactNativeImageResult(data: image.pngData()?.base64EncodedString() ?? "",
                                                  mWidth: image.size.width,
                                                  mHeight: image.size.height)
        }
        // Set the rest of the values to be equal to the normal result
        self.authenticity = nfcResult.authenticity
        self.confidentiality = nfcResult.confidentiality
        self.originality = nfcResult.originality
        self.mrzMatch = nfcResult.mrzMatch
        self.dataGroupHashesValid = nfcResult.dataGroupHashesValid
        self.bacSuccess = nfcResult.bacSuccess
        self.activeAuthenticationSuccess = nfcResult.activeAuthenticationSuccess
        self.chipAuthenticationSuccess = nfcResult.chipAuthenticationSuccess
        self.documentSignatureCorrect = nfcResult.documentSignatureCorrect
        self.documentCertificateValid = nfcResult.documentCertificateValid
        self.signingCertificateMatchesWithParent = nfcResult.signingCertificateMatchesWithParent
        self.scanCompleted = nfcResult.scanCompleted
        self.bacStatus = nfcResult.bacStatus
        self.activeAuthenticationStatus = nfcResult.activeAuthenticationStatus
        self.chipAuthenticationStatus = nfcResult.chipAuthenticationStatus
        self.mrzData = nfcResult.mrzData
        self.dataGroups = nfcResult.dataGroups
        self.dataGroupHashes = nfcResult.dataGroupHashes
        self.documentSpecificData = nfcResult.documentSpecificData
        self.documentCertificate = nfcResult.documentCertificate
        self.type = nfcResult.type
        self.sodHashes = nfcResult.sodHashes
        self.sodData = nfcResult.sodData
        self.aaDigestAlgorithm = nfcResult.aaDigestAlgorithm
        self.chipAuthenticationOid = nfcResult.chipAuthenticationOid
        self.signingCertificate = nfcResult.signingCertificate
        
    }
}
