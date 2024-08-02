#import "ReactNativeArculusCsdk.h"

@implementation ReactNativeArculusCsdk
RCT_EXPORT_MODULE()

// Example method
// See // https://reactnative.dev/docs/native-modules-ios
RCT_EXPORT_METHOD(multiply:(double)a
                  b:(double)b
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSNumber *result = @(aptoslabs_reactnativearculuscsdk::multiply(a, b));

    resolve(result);
}


@end
