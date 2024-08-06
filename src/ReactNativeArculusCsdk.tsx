import { NativeModules, Platform } from 'react-native';

import type { CardAlgorithm, CardCurve } from './types';

type ReactNativeArculusCsdkType = {
  createWalletSeed(
    pin: string,
    wordCount: number,
    path: string,
    curve: CardCurve
  ): Promise<string>;
  getGGUID(): Promise<string>;
  getPubKeyByPath(path: string, curve: CardCurve): Promise<string>;
  getVersion(): Promise<string>;
  signHashByPath(
    pin: string,
    path: string,
    curve: CardCurve,
    algorithm: CardAlgorithm,
    hash: string
  ): Promise<string>;
  storePIN(pin: string): Promise<boolean>;
  updatePIN(oldPin: string, newPin: string): Promise<boolean>;
  verifyPIN(pin: string): Promise<boolean>;
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
