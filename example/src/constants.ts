export const CARD_CURVES = [
  { label: 'secp256k1', value: 0x0100 },
  { label: 'ed25519', value: 0x0201 },
  { label: 'ed25519Blake2bNano', value: 0x0202 },
  { label: 'ed25519Curve', value: 0x0203 },
  { label: 'nist256p1', value: 0x0301 },
  { label: 'ed25519ExtendedCardano', value: 0x0401 },
  { label: 'sr25519', value: 0x0501 },
];

export const CARD_ALGORITHMS = [
  { label: 'ecdsa', value: 1 },
  { label: 'eddsa', value: 2 },
  { label: 'schnorr', value: 3 },
  { label: 'ristretto', value: 4 },
  { label: 'cardano', value: 5 },
];
