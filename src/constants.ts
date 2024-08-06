export const CARD_ALGORITHMS = {
  ECDSA: 1,
  EDDSA: 2,
  CARDANO: 5,
} as const;

export const CARD_CURVES = {
  SECP256K1: 0x0100,
  ED25519: 0x0201,
  ED25519_EXTENDED_CARDANO: 0x0401,
} as const;

export const CARD_CHAINS = {
  APTOS: {
    algorithm: CARD_ALGORITHMS.EDDSA,
    curve: CARD_CURVES.ED25519,
    path: "m/44'/637'/0'/0'/0'",
  },
  BITCOIN: {
    algorithm: CARD_ALGORITHMS.ECDSA,
    curve: CARD_CURVES.SECP256K1,
    path: "m/0'",
  },
  BITCOIN_CASH: {
    algorithm: CARD_ALGORITHMS.ECDSA,
    curve: CARD_CURVES.SECP256K1,
    path: "m/0'",
  },
  CARDANO: {
    algorithm: CARD_ALGORITHMS.CARDANO,
    curve: CARD_CURVES.ED25519_EXTENDED_CARDANO,
    path: "m/1852'/1815'/0'/0",
  },
  DOGECOIN: {
    algorithm: CARD_ALGORITHMS.ECDSA,
    curve: CARD_CURVES.SECP256K1,
    path: "m/44'/3'/0'/0",
  },
  ETHEREUM: {
    algorithm: CARD_ALGORITHMS.ECDSA,
    curve: CARD_CURVES.SECP256K1,
    path: "m/44'/60'/0'/0",
  },
  HEDERA: {
    algorithm: CARD_ALGORITHMS.EDDSA,
    curve: CARD_CURVES.ED25519,
    path: "m/44'/60'/0'/0",
  },
  LITECOIN: {
    algorithm: CARD_ALGORITHMS.ECDSA,
    curve: CARD_CURVES.SECP256K1,
    path: "m/44'/2'/0'/0",
  },
  SOLANA: {
    algorithm: CARD_ALGORITHMS.EDDSA,
    curve: CARD_CURVES.ED25519,
    path: "m/44'/501'/0'/0",
  },
  STELLAR: {
    algorithm: CARD_ALGORITHMS.EDDSA,
    curve: CARD_CURVES.ED25519,
    path: "m/44'/148'/0'/0",
  },
  XRP: {
    algorithm: CARD_ALGORITHMS.ECDSA,
    curve: CARD_CURVES.SECP256K1,
    path: "m/44'/144'/0'/0",
  },
} as const;
