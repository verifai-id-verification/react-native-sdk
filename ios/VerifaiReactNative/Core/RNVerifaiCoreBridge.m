//
//  RNVerifaiCoreBridge.m
//  VerifaiReactNative
//
//  Created by Richard Chirino on 06/01/2022.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNVerifaiCore, NSObject)
// Configuration
RCT_EXTERN_METHOD(setupConfiguration:(NSDictionary *));
// Core
RCT_EXTERN_METHOD(start:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject);

@end
