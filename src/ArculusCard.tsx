import ReactNativeArculusCsdk from './ReactNativeArculusCsdk';
import { validatePin } from './validators';

export type ChangePinArgs = {
  oldPIN: string;
  newPIN: string;
};

const changePIN = (args: ChangePinArgs): Promise<void> => {
  const { oldPIN, newPIN } = args;

  validatePin(oldPIN);
  validatePin(newPIN);

  return ReactNativeArculusCsdk.changePIN(oldPIN, newPIN);
};

export type CreateWalletArgs = {
  pin: string;
  nbrOfWords: number;
};

const createWallet = (args: CreateWalletArgs): Promise<string> => {
  const { pin, nbrOfWords } = args;

  validatePin(pin);

  return ReactNativeArculusCsdk.createWallet(pin, nbrOfWords);
};

const getFirmwareVersion = (): Promise<string> =>
  ReactNativeArculusCsdk.getFirmwareVersion();

const getGGUID = (): Promise<string> => ReactNativeArculusCsdk.getGGUID();

export type GetInfoArgs = {
  path: string;
  curve: number;
};

const getInfo = (
  args: GetInfoArgs
): Promise<{ gguid: string; publicKey: string; chainCodeKey: string }> => {
  const { path, curve } = args;

  return ReactNativeArculusCsdk.getInfo(path, curve);
};

export type GetPublicKeyFromPathArgs = {
  path: string;
  curve: number;
};

const getPublicKeyFromPath = (
  args: GetPublicKeyFromPathArgs
): Promise<{ publicKey: string; chainCodeKey: string }> => {
  const { path, curve } = args;

  return ReactNativeArculusCsdk.getPublicKeyFromPath(path, curve);
};

const resetWallet = (): Promise<void> => ReactNativeArculusCsdk.resetWallet();

export type RestoreWalletArgs = {
  pin: string;
  mnemonicSentence: string;
};

const restoreWallet = (args: RestoreWalletArgs): Promise<void> => {
  const { pin, mnemonicSentence } = args;

  validatePin(pin);

  return ReactNativeArculusCsdk.restoreWallet(pin, mnemonicSentence);
};

export type SignHashArgs = {
  pin: string;
  path: string;
  curve: number;
  algorithm: number;
  hash: string;
};

const signHash = (args: SignHashArgs): Promise<string> => {
  const { pin, path, curve, algorithm, hash } = args;

  validatePin(pin);

  return ReactNativeArculusCsdk.signHash(pin, path, curve, algorithm, hash);
};

export type VerifyPinArgs = {
  pin: string;
};

const verifyPIN = (args: VerifyPinArgs): Promise<void> => {
  const { pin } = args;

  validatePin(pin);

  return ReactNativeArculusCsdk.verifyPIN(pin);
};

const ArculusCard = {
  changePIN,
  createWallet,
  getFirmwareVersion,
  getGGUID,
  getInfo,
  getPublicKeyFromPath,
  resetWallet,
  restoreWallet,
  signHash,
  verifyPIN,
};

export default ArculusCard;
