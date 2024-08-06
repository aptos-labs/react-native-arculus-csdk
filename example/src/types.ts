export enum CMD {
  GetGGUID,
  GetVersion,
  CreateWalletSeed,
  CreateAptosWalletSeed,
  RestoreWalletSeed,
  ResetWallet,
  VerifyPIN,
  SignHashPath,
  SignAptosHash,
  UpdatePIN,
  StorePIN,
  GetPubKeyByPath,
  GetAptosPubKey,
}

export type Command = {
  cmd: CMD;
  name: string;
  inp1: string | null;
  inp2: string | null;
  out: string;
};

export type RootStackParamList = {
  Commands: undefined;
  Output: { command: Command };
};
