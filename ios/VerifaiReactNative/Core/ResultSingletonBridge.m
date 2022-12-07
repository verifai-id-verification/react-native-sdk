//
//  ResultSingletonBridge.m
//  VerifaiReactNative
//
//  Created by Richard Chirino on 21/01/2022.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(VerifaiResultManager, NSObject)

// Clear result object
RCT_EXTERN_METHOD(clearResult);
// Main queue setup
RCT_EXTERN_METHOD(requiresMainQueueSetup);

@end
