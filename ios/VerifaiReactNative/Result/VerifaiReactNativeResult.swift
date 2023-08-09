//
//  VerifaiReactNativeResult.swift
//  VerifaiReactNative
//
//  Created by Richard Chirino on 20/01/2022.
//

import Foundation
import VerifaiCommonsKit
import VerifaiKit


/// To work well with react native we encode the VerifaiResult object differently than in the
/// native SDK's, this ensures the data can be parsed by Javascript
class VerifaiReactNativeResult: Codable {
    
    let frontImage: VerifaiReactNativeImageResult?
    let frontDocumentPosition: CGRect?
    let backImage: VerifaiReactNativeImageResult?
    let backDocumentPosition: CGRect?
    let mrzData: VerifaiMRZModel?
    let idModel: VerifaiDocumentResult?
    let documentBarcodes: [VerifaiBarcodeResult]?
    let visualInspectionZoneResult: VerifaiVisualInspectionZoneResult?
    
    init(result: VerifaiLocalCoreResult) {
        // Define react native front image
        let front = VerifaiReactNativeImageResult(base64: result.frontImage?.pngData()?.base64EncodedString() ?? "",
                                                  width: result.frontImage?.size.width ?? 1,
                                                  height: result.frontImage?.size.height ?? 1)
        // Define react native back image
        let back = VerifaiReactNativeImageResult(base64: result.backImage?.pngData()?.base64EncodedString() ?? "",
                                                 width: result.backImage?.size.width ?? 1,
                                                 height: result.backImage?.size.height ?? 1)
        // Fill in the rest of the result
        self.frontImage = front
        self.frontDocumentPosition = result.frontDocumentPosition
        self.backImage = back
        self.backDocumentPosition = result.backDocumentPosition
        self.mrzData = result.mrzData
        self.idModel = result.idModel
        self.documentBarcodes = result.documentBarcodes
        self.visualInspectionZoneResult = result.visualInspectionZoneResult
    }
}
 
