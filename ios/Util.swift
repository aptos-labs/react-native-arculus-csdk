
enum CoinType: UInt16, CaseIterable {

    case aptos
    case bitcoin
    case bitcoinCash
    case ethereum
    case litecoin
    case dogecoin
    case cardano
    case xrp
    case solana
    case stellar
    case hedera

    var val: UInt16 {
        return self.rawValue
    }

    var curve: CardCurve {
        switch self{
        case.aptos:
            return CardCurve.ed25519
        case.bitcoin:
            return CardCurve.secp256k1
        case.bitcoinCash:
            return CardCurve.secp256k1
        case.ethereum:
            return CardCurve.secp256k1
        case.litecoin:
            return CardCurve.secp256k1
        case.dogecoin:
            return CardCurve.secp256k1
        case.cardano:
            return CardCurve.ed25519ExtendedCardano
        case.xrp:
            return CardCurve.secp256k1
        case.solana:
            return CardCurve.ed25519
        case.stellar:
            return CardCurve.ed25519
        case.hedera:
            return CardCurve.ed25519
        }
    }

    // Determine card curve/default hash algorithm curve
    var cardCurveAlgo: (CardCurve, CardAlgorithm)? {
        switch self.curve {
        case .secp256k1: return (.secp256k1, .ecdsa)
        case .ed25519: return (.ed25519, .eddsa)
        case .ed25519Blake2bNano: return (.ed25519Blake2bNano, .eddsa)
        case .ed25519ExtendedCardano: return (.ed25519ExtendedCardano, .eddsa)
        case .nist256p1: return (.nist256p1, .ecdsa)
        default: return nil
        }
    }

    func derivationPath() -> String {
        switch self{
        case.aptos:
            return "m/44'/637'/0'/0'/0'"
        case.bitcoin:
            return "m/0'"
        case.bitcoinCash:
            return "m/0'"
        case.ethereum:
            return "m/44'/60'/0'/0"
        case.litecoin:
            return "m/44'/2'/0'/0"
        case.dogecoin:
            return "m/44'/3'/0'/0"
        case.cardano:
            return "m/1852'/1815'/0'/0"
        case.xrp:
            return "m/44'/144'/0'/0"
        case.solana:
            return "m/44'/501'/0'/0"
        case.stellar:
            return "m/44'/148'/0'/0"
        case.hedera:
            return "m/44'/60'/0'/0"
        }
    }

    var hardenedPath: String? {
        return self.derivationPath()
    }

}
