#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativeArculusCsdk, NSObject)

RCT_EXTERN_METHOD(changePIN:(nonnull NSString *)oldPIN
                  withNewPIN:(nonnull NSString *)newPIN
                  withResolver:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(createWallet:(nonnull NSString *)pin
                  withNumberOfWords:(nonnull NSNumber *)nbrOfWords
                  withResolver:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getFirmwareVersion:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getGGUID:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getInfo:(nonnull NSString *)path
                  withCurve:(nonnull NSNumber *)curve
                  withResolver:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(getPublicKeyFromPath:(nonnull NSString *)path
                  withCurve:(nonnull NSNumber *)curve
                  withResolver:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(resetWallet:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(restoreWallet:(nonnull NSString *)pin
                  withMnemonicSentence:(nonnull NSString *)mnemonicSentence
                  withResolver:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(signHash:(nonnull NSString *)pin
                  withPath:(nonnull NSString *)path
                  withCurve:(nonnull NSNumber *)curve
                  withAlgorithm:(nonnull NSNumber *)algorithm
                  withHash:(nonnull NSString *)hash
                  withResolver:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

RCT_EXTERN_METHOD(verifyPIN:(nonnull NSString *)pin
                  withResolver:(nonnull RCTPromiseResolveBlock)resolve
                  withRejecter:(nonnull RCTPromiseRejectBlock)reject)

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

@end
