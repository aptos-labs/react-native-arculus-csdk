#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativeArculusCsdk, NSObject)

RCT_EXTERN_METHOD(createWalletSeed:(nonnull NSString *)pin
                  withWordCount:(nonnull NSNumber *)wordCount
                  withPath:(nonnull NSString *)path
                  withCurve:(nonnull NSString *)curve
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getPubKeyByPath:(nonnull NSString *)path
                  withCurve:(nonnull NSString *)curve
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signHashByPath:(nonnull NSString *)pin
                  withPath:(nonnull NSString *)path
                  withCurve:(nonnull NSString *)curve
                  withAlgorithm:(nonnull NSString *)algorithm
                  withHash:(nonnull NSString *)hash
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

//

RCT_EXTERN_METHOD(getGGUID:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getVersion:(RCTPromiseResolveBlock)resolve withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(verifyPIN:(NSString *)pin
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(storePIN:(NSString *)pin
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(updatePIN:(NSString *)oldPin withNewPin:(NSString *)newPin
                  withResolver:(RCTPromiseResolveBlock)resolve
                  withRejecter:(RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
