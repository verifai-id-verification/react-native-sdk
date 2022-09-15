//
//  NFCBridge.m
//  VerifaiReactNative
//
//  Created by Richard Chirino on 20/01/2022.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(NFC, NSObject)

// Listeners
RCT_EXTERN_METHOD(setOnSuccess:(RCTResponseSenderBlock *));
RCT_EXTERN_METHOD(setOnCancelled:(RCTResponseSenderBlock *));
RCT_EXTERN_METHOD(setOnError:(RCTResponseSenderBlock *));

// NFC
RCT_EXTERN_METHOD(start:(NSDictionary *))

// Main queue setup
RCT_EXTERN_METHOD(requiresMainQueueSetup);

@end
