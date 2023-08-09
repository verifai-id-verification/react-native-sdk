//
//  VerifaiAPINFCResult.swift
//  verifai-react-native
//
//  Created by Nadia Ruocco on 22/03/2023.
//

import Foundation
import VerifaiNFCKit
import VerifaiCommonsKit

class VerifaiAPINFCResult: Codable {
    
    var mrzData: VerifaiMRZModel?
    var frontImage: VerifaiReactNativeImageResult?
    var faceImage: VerifaiReactNativeImageResult?
    var nfcError: VerifaiNFCError?
    
    init(nfcAPIResult: VerifaiNFCResult) {
        
       // Define react native front image
        let front = VerifaiReactNativeImageResult(base64: nfcAPIResult.frontImage?.pngData()?.base64EncodedString() ?? "",
                                                  width: nfcAPIResult.frontImage?.size.width ?? 1,
                                                  height: nfcAPIResult.frontImage?.size.height ?? 1)
        
        // Define react native face image
        let face = VerifaiReactNativeImageResult(base64: nfcAPIResult.faceImage?.pngData()?.base64EncodedString() ?? "",
                                                 width: nfcAPIResult.faceImage?.size.width ?? 1,
                                                 height: nfcAPIResult.faceImage?.size.height ?? 1)
        // Set the other values
        self.mrzData = nfcAPIResult.mrzData
        self.frontImage = front
        self.faceImage = face
        self.nfcError = nfcAPIResult.nfcError
    }
}

