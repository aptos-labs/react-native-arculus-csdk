import { NativeModules, Platform } from 'react-native';

type ReactNativeArculusCsdkType = {
  changePIN(oldPIN: string, newPIN: string): Promise<void>;
  createWallet(pin: string, nbrOfWords: number): Promise<string>;
  getFirmwareVersion(): Promise<string>;
  getGGUID(): Promise<string>;
  getInfo(
    path: string,
    curve: number
  ): Promise<{ gguid: string; publicKey: string; chainCodeKey: string }>;
  getPublicKeyFromPath(
    path: string,
    curve: number
  ): Promise<{ publicKey: string; chainCodeKey: string }>;
  resetWallet(): Promise<void>;
  restoreWallet(pin: string, mnemonicSentence: string): Promise<void>;
  signHash(
    pin: string,
    path: string,
    curve: number,
    algorithm: number,
    hash: string
  ): Promise<string>;
  verifyPIN(pin: string): Promise<void>;
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
