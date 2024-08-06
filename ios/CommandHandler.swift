import CoreNFC

class Command {
    fileprivate var cardService = CardService()
    
    func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        fatalError("This method must be overridden")
    }
}

class CreateWalletSeedCommand: Command {
    private let pin: String
    private let wordCount: Int
    private let path: String
    private let curve: String
    
    init(pin: String, wordCount: Int, path: String, curve: String) {
        self.pin = pin
        self.wordCount = wordCount
        self.path = path
        self.curve = curve
    }
    
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.startCreateWalletSeed(tag: tag, pin: pin, wordCount: wordCount) { result in
            switch result {
            case .success(let words):
                guard let seed = self.cardService.seedFromWords(words: words) else {
                    completion(.failure(CardReaderError.operationFailed))
                    return
                }
                self.cardService.finishCreateWalletSeed(tag: tag, pin: self.pin, seed: seed) { [weak self] result in
                    guard let self = self else {
                        completion(.failure(CardReaderError.operationFailed))
                        return
                    }
                    
                    self.cardService.getPublicKeyByPathv2(tag: tag, path: path, curve: getCurveFromString(curveString: curve)).done { pubKey in
                        completion(.success(["words": words, "pubKey": dump(data: pubKey.publicKey)]))
                    }.catch { error in
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class GetPubKeyByPathCommand: Command {
    private let path: String
    private let curve: String
    
    init(path: String, curve: String) {
        self.path = path
        self.curve = curve
    }
    
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.getPubKeyByPath(tag: tag, path: path, curve: getCurveFromString(curveString: curve)) { result in
            switch result {
            case .success(let pubKey):
                completion(.success(dump(data: pubKey.publicKey)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class SignHashByPathCommand: Command {
    private let pin: String
    private let path: String
    private let curve: String
    private let algorithm: String
    private let hash: String
    
    init(pin: String, path: String, curve: String, algorithm: String, hash: String) {
        self.pin = pin
        self.path = path
        self.curve = curve
        self.algorithm = algorithm
        self.hash = hash
    }
    
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        guard let hashData = strToData(hash) else { return }
        
        cardService.signHashPath(
            tag: tag,
            pin: pin,
            path: path,
            curve: getCurveFromString(curveString: curve),
            algorithm: getHashAlgorithmFromString(hashAlgorithmString: algorithm),
            hash: hashData
        ) { result in
            switch result {
            case .success(let signedHash):
                completion(.success(dump(data: signedHash)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

//

class GetGGUIDCommand: Command {
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.getGGUID(tag: tag) { result in
            switch result {
            case .success(let gguid):
                completion(.success(dump(data: gguid)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class GetVersionCommand: Command {
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.getFirmwareVersion(tag: tag) { result in
            switch result {
            case .success(let version):
                completion(.success(version))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class VerifyPINCommand: Command {
    private let pin: String
    
    init(pin: String) {
        self.pin = pin
    }
    
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.verifyPin(tag: tag, pin: pin) { result in
            switch result {
            case .success(let (success, _)):
                completion(.success(success))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class StorePINCommand: Command {
    private let pin: String
    
    init(pin: String) {
        self.pin = pin
    }
    
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.storePin(tag: tag, pin: pin) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class UpdatePINCommand: Command {
    private let oldPin: String
    private let newPin: String
    
    init(oldPin: String, newPin: String) {
        self.oldPin = oldPin
        self.newPin = newPin
    }
    
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.updatePin(tag: tag, oldPin: oldPin, newPin: newPin) { result in
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private func strToData(_ hexStr: String) -> Data? {
    if let arr = strToArr(hexStr) {
        return Data(arr)
    } else {
        return nil
    }
}

private func strToArr(_ hexStr: String) -> [UInt8]? {
    var arr: [UInt8] = []
    var val: UInt8 = 0
    if hexStr.count % 2 != 0 {
        return nil
    }
    for (ii, c) in hexStr.enumerated() {
        guard let v = UInt8(String(c), radix: 16) else { return nil }
        if ii % 2 == 0 {
            val = v
        } else {
            val = val << 4 | v
            arr.append(val)
            val = 0
        }
    }
    return arr
}
