//
//  CoreBridge.m
//  VerifaiReactNative
//
//  Created by Richard Chirino on 06/01/2022.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Core, NSObject)

// Licence
RCT_EXTERN_METHOD(setLicence:(NSString *));
// Listeners
RCT_EXTERN_METHOD(setOnSuccess:(RCTResponseSenderBlock *));
RCT_EXTERN_METHOD(setOnCancelled:(RCTResponseSenderBlock *));
RCT_EXTERN_METHOD(setOnError:(RCTResponseSenderBlock *));
// Configuration
RCT_EXTERN_METHOD(configure:(NSDictionary *));
// Core
RCT_EXTERN_METHOD(start);
// Main queue setup
RCT_EXTERN_METHOD(requiresMainQueueSetup);

@end
