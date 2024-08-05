import CoreNFC

class Command {
    fileprivate var cardService = CardService()

    func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        fatalError("This method must be overridden")
    }
}

class GetGGUIDCommand: Command {
    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.getGGUID(tag: tag) { result in
            switch result {
            case .success(let gguid):
                let response = dump(data: gguid)
                completion(.success(response))
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


class CreateAptosWalletSeedCommand: Command {
    private let pin: String

    init(pin: String) {
        self.pin = pin
    }

    override func execute(tag: NFCISO7816Tag, completion: @escaping (Result<Any, Error>) -> Void) {
        cardService.startCreateWalletSeed(tag: tag, pin: pin, wordCount: 12) { result in
            switch result {
            case .success(let words):
                guard let seed = self.cardService.seedFromWords(words: words) else {
                    completion(.failure(CardReaderError.operationFailed))
                    return
                }
                self.cardService.finishCreateWalletSeed(tag: tag, pin: self.pin, seed: seed) { result in
                    switch result {
                    case .failure(let error):
                        completion(.failure(error))
                    case .success:
                        completion(.success(words))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
