//
//  Error.swift
//  VerifaiReactNative
//
//  Created by Jeroen Oomkes on 04/07/2023.
//

import Foundation

struct ErrorType {
    // Shared
    static let resultConversion = "result_conversion_error"
    static let sdk = "verifai_sdk_error"
    static let unhandled = "unhandled_error"
    static let canceled = "canceled"
    static let configuration = "configuration_error"
    static let license = "set_license_error"
    static let liveness = "liveness_check_error"
  
    // iOS specific
    static let noView = "no_view_controller"
}
