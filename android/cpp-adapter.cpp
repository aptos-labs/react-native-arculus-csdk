#include <jni.h>
#include "aptos-labs-react-native-arculus-csdk.h"

extern "C"
JNIEXPORT jdouble JNICALL
Java_com_aptoslabs_reactnativearculuscsdk_ReactNativeArculusCsdkModule_nativeMultiply(JNIEnv *env, jclass type, jdouble a, jdouble b) {
    return aptoslabs_reactnativearculuscsdk::multiply(a, b);
}
