import { NativeModules, Platform } from 'react-native';

type ReactNativeArculusCsdkType = {
  multiply(a: number, b: number): Promise<number>;
  getGGUID(): Promise<any>;
  getVersion(): Promise<any>;
  verifyPIN(pin: string): Promise<any>;
  storePIN(pin: string): Promise<any>;
  updatePIN(oldPin: string, newPin: string): Promise<any>;
  createWalletSeed(pin: string, wordCount: string): Promise<any>;
  createAptosWalletSeed(pin: string): Promise<any>;
  signAptosHash(pin: string, hash: string): Promise<any>;
};

const LINKING_ERROR =
  `The package '@aptos-labs/react-native-arculus-csdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const ReactNativeArculusCsdk: ReactNativeArculusCsdkType =
  NativeModules.ReactNativeArculusCsdk
    ? NativeModules.ReactNativeArculusCsdk
    : new Proxy(
        {},
        {
          get() {
            throw new Error(LINKING_ERROR);
          },
        }
      );

export default ReactNativeArculusCsdk;
