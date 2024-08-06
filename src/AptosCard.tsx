import ArculusCard, {
  type CreateWalletArgs,
  type SignHashArgs,
} from './ArculusCard';

import { CARD_CHAINS } from './constants';

export type CreateAptosWalletArgs = Omit<CreateWalletArgs, 'nbrOfWords'>;

export const createWallet = (args: CreateAptosWalletArgs): Promise<string> =>
  ArculusCard.createWallet({
    ...args,
    nbrOfWords: 12,
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
  createWallet,
  getPublicKey,
  signHash,
};

export default AptosCard;
