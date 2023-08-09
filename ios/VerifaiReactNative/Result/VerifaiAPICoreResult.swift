//
//  VerifaiAPICoreResult.swift
//  verifai-react-native
//
//  Created by Nadia Ruocco on 22/03/2023.
//

import Foundation
import VerifaiCommonsKit

class VerifaiAPICoreResult: Codable {
    
    var frontImage: VerifaiReactNativeImageResult?
    var mrzData: VerifaiMRZModel?
    
    init(coreAPIResult: VerifaiCoreResult) {
        
       // Define react native front image
        let frontImage = VerifaiReactNativeImageResult(base64: coreAPIResult.frontImage?.pngData()?.base64EncodedString() ?? "",
                                                       width: coreAPIResult.frontImage?.size.width ?? 1,
                                                       height: coreAPIResult.frontImage?.size.height ?? 1)
     
        // Set the other values
        self.frontImage = frontImage
        self.mrzData = coreAPIResult.mrzData
    }
}
