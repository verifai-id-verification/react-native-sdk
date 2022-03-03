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
    let resultFlowInformation: VerifaiResultFlowInformation?
    let documentBarcodes: [VerifaiBarcodeResult]?
    let frontVisualInspectionZoneResult: VerifaiVisualInspectionZoneResult?
    let backVisualInspectionZoneResult: VerifaiVisualInspectionZoneResult?
    
    init(result: VerifaiResult) {
        // Define react native front image
        let front = VerifaiReactNativeImageResult(data: result.frontImage?.pngData()?.base64EncodedString() ?? "",
                                                  mWidth: result.frontImage?.size.width ?? 1,
                                                  mHeight: result.frontImage?.size.height ?? 1)
        // Define react native back image
        let back = VerifaiReactNativeImageResult(data: result.backImage?.pngData()?.base64EncodedString() ?? "",
                                                 mWidth: result.backImage?.size.width ?? 1,
                                                 mHeight: result.backImage?.size.height ?? 1)
        // Fill in the rest of the result
        self.frontImage = front
        self.frontDocumentPosition = result.frontDocumentPosition
        self.backImage = back
        self.backDocumentPosition = result.backDocumentPosition
        self.mrzData = result.mrzData
        self.idModel = result.idModel
        self.resultFlowInformation = result.resultFlowInformation
        self.documentBarcodes = result.documentBarcodes
        self.frontVisualInspectionZoneResult = result.frontVisualInspectionZoneResult
        self.backVisualInspectionZoneResult = result.backVisualInspectionZoneResult
    }
}
