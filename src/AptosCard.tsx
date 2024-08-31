import ArculusCard, {
  type CreateWalletArgs,
  type SignHashArgs,
} from './ArculusCard';

import { CARD_CHAINS } from './constants';

const {
  changePIN,
  getFirmwareVersion,
  getGGUID,
  resetWallet,
  restoreWallet,
  setNFCTagReaderAlertMessage,
  verifyPIN,
} = ArculusCard;

export type CreateAptosWalletArgs = Omit<CreateWalletArgs, 'nbrOfWords'>;

export const createWallet = (args: CreateAptosWalletArgs): Promise<string> =>
  ArculusCard.createWallet({
    ...args,
    nbrOfWords: 12,
  });

export const getInfo = () =>
  ArculusCard.getInfo({
    path: CARD_CHAINS.APTOS.path,
    curve: CARD_CHAINS.APTOS.curve,
  });

export const getPublicKey = () =>
  ArculusCard.getPublicKeyFromPath({
    path: CARD_CHAINS.APTOS.path,
    curve: CARD_CHAINS.APTOS.curve,
  });

type SignAptosHashArgs = Omit<SignHashArgs, 'path' | 'curve' | 'algorithm'>;

export const signHash = (args: SignAptosHashArgs): Promise<string> =>
  ArculusCard.signHash({
    ...args,
    path: CARD_CHAINS.APTOS.path,
    curve: CARD_CHAINS.APTOS.curve,
    algorithm: CARD_CHAINS.APTOS.algorithm,
  });

const AptosCard = {
  changePIN,
  createWallet,
  getFirmwareVersion,
  getGGUID,
  getInfo,
  getPublicKey,
  resetWallet,
  restoreWallet,
  setNFCTagReaderAlertMessage,
  signHash,
  verifyPIN,
};

export default AptosCard;
