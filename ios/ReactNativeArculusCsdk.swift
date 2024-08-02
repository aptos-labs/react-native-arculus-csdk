import CoreNFC
import PromiseKit

enum Command {
    case GetGGUID
    case GetVersion
    case CreateWalletSeed
    case CreateAptosWalletSeed
    case RestoreWallet
    case RestoreWalletSeed
    case ResetWallet
    case VerifyPIN
    case SignHashPath
    case UpdatePIN
    case StorePIN
    case GetPubKeyByPath
}

public func dump(data: Data?, sep: String = "") -> String {
    var str = ""
    if let data = data {
        for c in data {
            str += String(format: "%02X", c)
            str += sep
        }
    } else {
        str = "None"
    }
    return str
}

@objc(ReactNativeArculusCsdk)
class ReactNativeArculusCsdk: NSObject, NFCTagReaderSessionDelegate {

    private var resolve: RCTPromiseResolveBlock?
    private var reject: RCTPromiseRejectBlock?

    private var cardReaderSession: NFCTagReaderSession?

    private var input1: String?
    private var input2: String?
    private var cmd: Command?

    private var cardService = CardService()

    private var isSessionInvalidated = false


    @objc(multiply:withB:withResolver:withRejecter:)
    func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        resolve(a*b)
    }

    @objc(getGGUID:withRejecter:)
    func getGGUID(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject

        cmd = .GetGGUID

        beginSession()
    }

    @objc(getVersion:withRejecter:)
    func getVersion(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject

        cmd = .GetVersion

        beginSession()
    }

    @objc(verifyPIN:withResolver:withRejecter:)
    func verifyPIN(pin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject

        cmd = .VerifyPIN
        input1 = pin

        beginSession()
    }

    @objc(storePIN:withResolver:withRejecter:)
    func storePIN(pin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject

        cmd = .StorePIN
        input1 = pin

        beginSession()
    }

    @objc(updatePIN:withNewPin:withResolver:withRejecter:)
    func updatePIN(oldPin: String, newPin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject

        cmd = .UpdatePIN
        input1 = oldPin
        input2 = newPin

        beginSession()
    }

    @objc(createWalletSeed:withWordCount:withResolver:withRejecter:)
    func createWalletSeed(pin: String, wordCount: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject

        cmd = .CreateWalletSeed
        input1 = pin
        input2 = wordCount

        beginSession()
    }

    @objc(createAptosWalletSeed:withResolver:withRejecter:)
    func createAptosWalletSeed(pin: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.resolve = resolve
        self.reject = reject

        cmd = .CreateAptosWalletSeed
        input1 = pin

        beginSession()
    }

    private func beginSession() {
        isSessionInvalidated = false
        cardReaderSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: .main)
        cardReaderSession?.alertMessage = "Hold your card to the back of your smartphone for up to a minute"
        cardReaderSession?.begin()
    }

    private func invalidateSession(_ isComplete: Bool = false, error: String? = nil) {
        isSessionInvalidated = isComplete
        if let err = error {
            cardReaderSession?.invalidate(errorMessage: err)
        } else {
            cardReaderSession?.invalidate()
        }
        cardReaderSession = nil
    }

    private func connect(session: NFCTagReaderSession, tag: NFCTag) -> Promise<Void> {
        return Promise { seal in
            session.connect(to: tag) { error in
                if let error = error {
                    seal.reject(error)
                } else {
                    seal.fulfill(())
                }
            }
        }
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        var tag: NFCTag?
        for nfcTag in tags {
            if case .iso7816 = nfcTag {
                tag = nfcTag
                break
            }
        }

        guard let cardTag = tag, case let .iso7816(isoTag) = tag else {
            self.invalidateSession(error: "Connection Lost.")
            return
        }

        firstly {
            connect(session: session, tag: cardTag)
        }.done { [weak self] in
            self?.sendCommand(tag: isoTag)
        }.catch { error in
            self.reject?("NFC_READ_ERROR", "Error: card read failed", error)
        }
    }

    private func onSessionFailed() {
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let nfcError = error as? NFCReaderError, nfcError.code != .readerSessionInvalidationErrorUserCanceled {
            self.reject?("NFC_READ_ERROR", "tagReaderSession error", error)
        }
        let codes: [NFCReaderError.Code] = [.readerSessionInvalidationErrorSessionTimeout,
                                            .readerSessionInvalidationErrorSessionTerminatedUnexpectedly,
                                            .readerSessionInvalidationErrorUserCanceled]
        if let nfcError = error as? NFCReaderError, codes.contains(nfcError.code), !isSessionInvalidated {
            onSessionFailed()
        }
    }

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}

    private func handleOutput<T>(_ result: Swift.Result<T, Error>, formatOutput: (T) -> String) {
        switch result {
        case .failure(let error):
            self.invalidateSession(error: error.localizedDescription)
        case .success(let val):
            let out = formatOutput(val)
            self.invalidateSession(true)
            self.resolve?(out)
        }
    }

    private func sendCommand(tag: NFCISO7816Tag) {
        switch self.cmd {
        case .GetGGUID:
            cardService.getGGUID(tag: tag) { [weak self] result in
                self?.handleOutput(result) { gguid in dump(data: gguid) }
            }
        case .GetVersion:
            cardService.getFirmwareVersion(tag: tag) { [weak self] result in
                self?.handleOutput(result) { $0 }
            }
        case .UpdatePIN:
            let oldPin = input1!
            let newPin = input2!
            cardService.updatePin(tag: tag, oldPin: oldPin, newPin: newPin) { [weak self] result in
                self?.handleOutput(result) { _ in "PIN changed successfully." }
            }
        case .VerifyPIN:
            let pin = input1!
            cardService.verifyPin(tag: tag, pin: pin) { [weak self] result in
                self?.handleOutput(result) { (success, tries) in success ? "PIN verified (tries=\(tries))." : "PIN incorrect, \(tries) tries remaining" }
            }
        case .StorePIN:
            let pin = input1!
            cardService.storePin(tag: tag, pin: pin) { [weak self] result in
                self?.handleOutput(result) { _ in "PIN stored." }
            }
        case .CreateWalletSeed:
            let pin = input1!
            let wcount = Int(input2!)!
            let ts1 = Date().timeIntervalSince1970
            cardService.startCreateWalletSeed(tag: tag, pin: pin, wordCount: wcount) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.invalidateSession(error: error.localizedDescription)
                case .success(let words):
                    guard let seed = self?.cardService.seedFromWords(words: words) else {
                        self?.invalidateSession(error: "Failed to generate seed from words")
                        return
                    }
                    self?.cardService.finishCreateWalletSeed(tag: tag, pin: pin, seed: seed)  { [weak self] result in
                        func getByPath(_ coin: CoinType) -> Promise<PubKey> {
                            guard let self = self,
                                  let (curve, _) = coin.cardCurveAlgo,
                                  let hardenedPath = coin.hardenedPath else {
                                return Promise(error: CardReaderError.operationFailed)
                            }
                            return self.cardService.getPublicKeyByPathv2(tag: tag, path: hardenedPath, curve: curve)
                        }
                        let coins: [CoinType] = [.aptos, .bitcoin, .bitcoinCash, .ethereum, .xrp, .litecoin, .dogecoin, .solana, .stellar, .hedera, .cardano]
                        coins.promiseMap(getByPath) { results in
                            let ts2 = Date().timeIntervalSince1970
                            let result: Swift.Result<[(CoinType, PubKey)], Error> = .success(results)
                            self?.handleOutput(result) { cpks in
                                var out = "Wallet Created.\nNew words: \(words)\n"
                                out += "Elapsed time: \(ts2 - ts1) sec\n"
                                out += "\nKeys:\n"
                                for k in cpks {
                                    out += "Currency: \(k.0)\n"
                                    out += "Chaincode: \(dump(data: k.1.chainCode))\n"
                                    out += "Pubkey: \(dump(data: k.1.publicKey))\n\n"
                                }
                                return out
                            }
                        }
                    }
                }
            }
        case .CreateAptosWalletSeed:
            let pin = input1!
            let ts1 = Date().timeIntervalSince1970
            cardService.startCreateWalletSeed(tag: tag, pin: pin, wordCount: 12) { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.invalidateSession(error: error.localizedDescription)
                case .success(let words):
                    guard let seed = self?.cardService.seedFromWords(words: words) else {
                        self?.invalidateSession(error: "Failed to generate seed from words")
                        return
                    }
                    self?.cardService.finishCreateWalletSeed(tag: tag, pin: pin, seed: seed) { [weak self] result in
                        switch result {
                        case .failure(let error):
                            self?.invalidateSession(error: error.localizedDescription)
                        case .success:
                            guard let self = self,
                                  let (curve, _) = CoinType.aptos.cardCurveAlgo,
                                  let hardenedPath = CoinType.aptos.hardenedPath else {
                                self?.invalidateSession(error: "Failed to get card curve or derivation path")
                                return
                            }
                            self.cardService.getPublicKeyByPathv2(tag: tag, path: hardenedPath, curve: curve).done { pubKey in
                                let ts2 = Date().timeIntervalSince1970
                                let result: Swift.Result<[(CoinType, PubKey)], Error> = .success([(.aptos, pubKey)])
                                self.handleOutput(result) { cpks in
                                    var out = "Wallet Created.\nNew words: \(words)\n"
                                    out += "Elapsed time: \(ts2 - ts1) sec\n"
                                    out += "\nKeys:\n"
                                    for k in cpks {
                                        out += "Currency: \(k.0)\n"
                                        out += "Chaincode: \(dump(data: k.1.chainCode))\n"
                                        out += "Pubkey: \(dump(data: k.1.publicKey))\n\n"
                                    }
                                    return out
                                }
                            }.catch { error in
                                self.invalidateSession(error: error.localizedDescription)
                            }
                        }
                    }
                }
            }

            //         case .RestoreWalletSeed:
            //             let pin = input1
            //             if !isValidPin(pin) {
            //                 self.invalidateSession(error: "Invalid PIN, must be string of 4-12 decimal digits")
            //                 return
            //             }
            //             let phrase = input2
            //             let subs = phrase.split(separator: " ")
            //             let words = subs.map({ String($0) })
            //             if !validWords.contains(words.count) {
            //                 self.invalidateSession(error: "Secret phrase has wrong word count \(words.count).")
            //                 return
            //             }
            //             guard let seed = cardService.seedFromWords(words: words) else {
            //                 self.invalidateSession(error: "Failed to generate seed from words")
            //                 return
            //             }
            //
            //             cardService.restoreWalletSeed(tag: tag, pin: pin, words: words, seed: seed) { [weak self] res in
            //                 func getByPath(_ coin: CoinType) -> Promise<PubKey> {
            //                     guard let self = self,
            //                           let (curve, _) = coin.cardCurveAlgo,
            //                           let hardenedPath = coin.hardenedPath else {
            //                         return Promise(error: CardReaderError.operationFailed)
            //                     }
            //                     return self.cardService.getPublicKeyByPathv2(tag: tag, path: hardenedPath, curve: curve)
            //                 }
            //                 switch res {
            //                 case .failure(let error): self?.invalidateSession(error: error.localizedDescription)
            //                 case .success:
            //                     let coins: [CoinType] = [.bitcoin, .bitcoinCash, .ethereum, .xrp, .litecoin, .dogecoin, .solana, .stellar, .hedera, .cardano]
            //                     coins.promiseMap(getByPath) { results in
            //                         let result: Swift.Result<[(CoinType, PubKey)], Error> = .success(results)
            //                         self?.handleOutput(result) { cpks in
            //                             var out = "Wallet Created.\nNew words: \(words)\n\nKeys:\n"
            //                             for k in cpks {
            //                                 out += "Currency: \(k.0)\n"
            //                                 out += "Chaincode: \(dump(data: k.1.chainCode))\n"
            //                                 out += "Pubkey: \(dump(data: k.1.publicKey))\n\n"
            //                             }
            //                             return out
            //                         }
            //                     }
            //                 }
            //             }
            //         case .GetPubKeyByPath:
            //             let pathTmp = input1
            //             let path = pathTmp.replacingOccurrences(of: "[’`‘]", with: "'", options: .regularExpression)
            //             let curveStr = input2
            //             let curveInt = UInt16(curveStr, radix: 16) ?? 0
            //             let curve = CardCurve(rawValue: curveInt) ?? .secp256k1
            //             cardService.getPubKeyByPath(tag: tag, path: path, curve: curve) { [weak self] result in
            //                 self?.handleOutput(result) { key in
            //                     var out = ""
            //                     out += "Chaincode: \(dump(data: key.chainCode))\n"
            //                     out += "Pubkey: \(dump(data: key.publicKey))\n"
            //                     return out
            //                 }
            //             }
            //         case .ResetWallet:
            //             cardService.resetWallet(tag: tag) { [weak self] result in
            //                 self?.handleOutput(result) { _ in
            //                     return "Wallet Reset."
            //                 }
            //             }
            //         case .SignHashPath:
            //             let inp1 = input1
            //             var subs: [Substring]
            //             if inp1.contains(",") {
            //                 subs = inp1.split(separator: ",")
            //             } else {
            //                 subs = inp1.split(separator: " ")
            //             }
            //             let words = subs.map({ String($0).strip() })
            //             if words.count < 2 {
            //                 setOutput("Invalid parameter, please enter pin and the path, separated by comma or space")
            //                 return
            //             }
            //             let pin = words[0]
            //             if !isValidPin(pin) {
            //                 self.invalidateSession(error: "Invalid PIN, must be string of 4-12 decimal digits")
            //                 return
            //             }
            //             let curve = getCurveFromString(curveString: selectedCurve)
            //             let algorithm = getHashAlgorithmFromString(hashAlgorithmString: selectedHashAlgorithm)
            //             let hashStr = input2
            //             let pathTmp = words[1]
            //             let path = pathTmp.replacingOccurrences(of: "[’`‘]", with: "'", options: .regularExpression)
            //
            //             guard let hash = strToData(hashStr) else { return }
            //             cardService.signHashPath(tag: tag, pin: pin, path: path, curve: curve, algorithm: algorithm, hash: hash) { [weak self] result in
            //                 self?.handleOutput(result) { signedHash in
            //                     dump(data: signedHash, sep: "")
            //                 }
            //             }

        default:
            break
        }

    }
}
