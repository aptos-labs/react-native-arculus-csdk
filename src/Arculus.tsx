import { CARD_CHAINS } from './constants';
import ReactNativeArculusCsdk from './ReactNativeArculusCsdk';
import type { CardAlgorithm, CardCurve } from './types';
import { validatePin, validateWordCount } from './validators';

export const createAptosWalletSeed = (pin: string) =>
  createWalletSeed(pin, 12, CARD_CHAINS.APTOS.path, CARD_CHAINS.APTOS.curve);

export const createWalletSeed = (
  pin: string,
  wordCount: number,
  path: string,
  curve: CardCurve
) => {
  validatePin(pin);
  validateWordCount(wordCount);

  return ReactNativeArculusCsdk.createWalletSeed(pin, wordCount, path, curve);
};

export const getAptosPubKey = () =>
  ReactNativeArculusCsdk.getPubKeyByPath(
    CARD_CHAINS.APTOS.path,
    CARD_CHAINS.APTOS.curve
  );

const signHashByPath = (
  pin: string,
  path: string,
  curve: CardCurve,
  algorithm: CardAlgorithm,
  hash: string
) => {
  validatePin(pin);

  return ReactNativeArculusCsdk.signHashByPath(
    pin,
    path,
    curve,
    algorithm,
    hash
  );
};

export const signAptosHash = (pin: string, hash: string) =>
  signHashByPath(
    pin,
    CARD_CHAINS.APTOS.path,
    CARD_CHAINS.APTOS.curve,
    CARD_CHAINS.APTOS.algorithm,
    hash
  );

const Arculus = {
  createAptosWalletSeed,
  createWalletSeed: ReactNativeArculusCsdk.createWalletSeed,
  getAptosPubKey,
  getGGUID: ReactNativeArculusCsdk.getGGUID,
  getPubKeyByPath: ReactNativeArculusCsdk.getPubKeyByPath,
  getVersion: ReactNativeArculusCsdk.getVersion,
  signAptosHash,
  signHashByPath: ReactNativeArculusCsdk.signHashByPath,
  storePIN: ReactNativeArculusCsdk.storePIN,
  updatePIN: ReactNativeArculusCsdk.updatePIN,
  verifyPIN: ReactNativeArculusCsdk.verifyPIN,
};

export default Arculus;

export * from './constants';
