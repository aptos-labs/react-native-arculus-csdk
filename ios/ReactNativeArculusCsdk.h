#ifdef __cplusplus
#import "aptos-labs-react-native-arculus-csdk.h"
#endif

#ifdef RCT_NEW_ARCH_ENABLED
#import "RNReactNativeArculusCsdkSpec.h"

@interface ReactNativeArculusCsdk : NSObject <NativeReactNativeArculusCsdkSpec>
#else
#import <React/RCTBridgeModule.h>

@interface ReactNativeArculusCsdk : NSObject <RCTBridgeModule>
#endif

@end
