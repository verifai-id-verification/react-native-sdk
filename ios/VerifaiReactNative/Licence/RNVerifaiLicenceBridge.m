//
//  RNVerifaiLicenceBridge.m
//  VerifaiReactNative
//
//  Created by Richard Chirino on 06/01/2022.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(RNVerifaiLicence, NSObject)

RCT_EXTERN_METHOD(setLicence:(NSString *)licence
                  resolver:(RCTPromiseResolveBlock)resolver
                  rejecter:(RCTPromiseRejectBlock)rejecter);

@end
