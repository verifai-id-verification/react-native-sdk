//
//  LivenessBridge.m
//  VerifaiReactNative
//
//  Created by Richard Chirino on 20/01/2022.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Liveness, NSObject)

// Configuration
RCT_EXTERN_METHOD(configure: (NSDictionary *)configuration
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject);


// Liveness module functions
RCT_EXTERN_METHOD(start: (NSArray *)checks
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject);

// Main queue setup
RCT_EXTERN_METHOD(requiresMainQueueSetup);

@end
