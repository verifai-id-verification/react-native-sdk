//
//  NFCBridge.m
//  VerifaiReactNative
//
//  Created by Richard Chirino on 20/01/2022.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(NFC, NSObject)

// License
RCT_EXTERN_METHOD(setLicense: (NSString *)license
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject);

// Configuration
RCT_EXTERN_METHOD(configure: (NSDictionary *)configuration
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject);

// NFC
RCT_EXTERN_METHOD(startLocal:(RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject);

// NFC API
RCT_EXTERN_METHOD(start: (NSString *)internalReference
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject);

// Main queue setup
RCT_EXTERN_METHOD(requiresMainQueueSetup);

@end
