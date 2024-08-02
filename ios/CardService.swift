/*
 * Copyright (c) 2021-2023 Arculus Holdings, L.L.C. All Rights Reserved.
 *
 * This software is confidential and proprietary information of Arculus Holdings, L.L.C.
 * All use and disclosure to third parties is subject to the confidentiality provisions
 * of the license agreement accompanying the associated software.
 *
 * This copyright notice and disclaimer shall be included with all copies of this
 * software used in derivative works.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR
 * A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS OF THIS SOFTWARE BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THIS SOFTWARE OR THE USE, MODIFICATION, DISTRIBUTION, OR OTHER DEALINGS IN THIS
 * SOFTWARE OR ITS DERIVATIVES.
 */

import PromiseKit
import CoreNFC

// Call a promise function sequentially on each element in an array
extension Array {
    func promiseMap<U>(_ f: @escaping (Element) -> Promise<U>, cb: @escaping ([(Element, U)]) -> Void) {
        var results: [(Element, U)] = []
        func recurse(_ arr: [Element]) -> Promise<U> {
            let fst = arr[0]
            if arr.count == 1 {
                return f(fst).then { r in
                    results.append((fst, r))
                    return Promise.value(r)
                }
            }
            let rest = Array(arr.dropFirst())
            return f(fst).then { r in
                results.append((fst, r))
                return recurse(rest)
            }.recover { err in
                return recurse(rest)
            }
        }
        firstly {
            recurse(self)
        }.done { _ in
            cb(results)
        }
    }
}

// High level card functions that call some number of low level operations, usually starting with selectWallet
class CardService {
    var cardVersion: CardVersion? = nil
    private let wallet = ArculusWallet()

    func seedFromWords(words: [String]) -> Data? {
        wallet.walletSeedFromWords(words: words)
    }

    func getGGUID(tag: NFCISO7816Tag, _ cb: @escaping (Swift.Result<Data, Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            return self.getGGUID(tag: tag)
        }.done { gguid in
            cb(.success(gguid))
        }.catch { error in
            cb(.failure(error))
        }
    }

    func getFirmwareVersion(tag: NFCISO7816Tag, _ cb: @escaping (Swift.Result<String, Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            return self.getFirmwareVersion(tag: tag)
        }.done { version in
            cb(.success(version))
        }.catch { error in
            cb(.failure(error))
        }
    }

    func verifyPin(tag: NFCISO7816Tag, pin: String, _ cb: @escaping (Swift.Result<(Bool, Int), Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            self.verifyPin(tag: tag, pin: pin)
        }.done { (success, tries) in
            if !success {
                if tries != -1 {
                    throw CardReaderError.verifyPinFailed(tries)
                } else {
                    throw CardReaderError.operationFailed
                }
            }
            cb(.success((success, tries)))
        }.catch { error in
            cb(.failure(error))
        }
    }

    func storePin(tag: NFCISO7816Tag, pin: String, _ cb: @escaping (Swift.Result<Bool, Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            self.storePin(tag: tag, pin: pin)
        }.done {
            cb(.success(true))
        }.catch { error in
            cb(.failure(error))
        }
    }
    func updatePin(tag: NFCISO7816Tag, oldPin: String, newPin: String, _ cb: @escaping (Swift.Result<Bool, Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            self.verifyPin(tag: tag, pin: oldPin)
        }.then { (success, tries) -> Promise<Void> in
            if !success {
                if tries != -1 {
                    throw CardReaderError.verifyPinFailed(tries)
                } else {
                    throw CardReaderError.operationFailed
                }
            }
            return self.storePin(tag: tag, pin: newPin)
        }.done {
            cb(.success(true))
        }.catch { error in
            cb(.failure(error))
        }
    }

    // Begin the process of creating a wallet using off-card seed
    func startCreateWalletSeed(tag: NFCISO7816Tag, pin: String, wordCount: Int, _ cb: @escaping (Swift.Result<[String], Error>) -> Void) {
        var authWords: [String] = []
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            self.resetWallet(tag: tag)
        }.then {
            self.storePin(tag: tag, pin: pin)
        }.then {
            self.createWalletSeed(tag: tag, wordCount: wordCount)
        }.done { words in
            authWords = words
        }.then {
            self.initRecoverWallet(tag: tag, wordCount: wordCount)
        }.done {
            cb(.success(authWords))
        }.catch { error in
            cb(.failure(error))
        }
    }

    // Complete wallet creation with off-card seed (no accounts created)
    func finishCreateWalletSeed(tag: NFCISO7816Tag, pin: String, seed: Data,
                                _ cb: @escaping (Swift.Result<Void, Error>) -> Void) {
        firstly {
            self.finishRecoverWalletSeed(tag: tag, seed: seed)
        }.then {
            return self.verifyPin(tag: tag, pin: pin)
        }.done { (success, tries) in
            cb(.success(()))
        }.catch { error in
            cb(.failure(error))
        }
    }

    func restoreWalletSeed(tag: NFCISO7816Tag, pin: String, words: [String], seed: Data,
                           _ cb: @escaping (Swift.Result<Void, Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            self.resetWallet(tag: tag)
        }.then {
            self.storePin(tag: tag, pin: pin)
        }.then {
            self.initRecoverWallet(tag: tag, wordCount: words.count)
        }.then {
            self.finishRecoverWalletSeed(tag: tag, seed: seed)
        }.then {
            self.verifyPin(tag: tag, pin: pin)
        }.done { (success, tries) in
            cb(.success(()))
        }.catch { error in
            cb(.failure(error))
        }
    }

    func resetWallet(tag: NFCISO7816Tag, _ cb: @escaping (Swift.Result<Bool, Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            self.resetWallet(tag: tag)
        }.done {
            cb(.success(true))
        }.catch { error in
            cb(.failure(error))
        }
    }

    func getPubKeyByPath(tag: NFCISO7816Tag, path: String, curve: CardCurve, cb: @escaping (Swift.Result<PubKey, Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            switch self.cardVersion {
            case .card2:
                return self.getPublicKeyByPathv2(tag: tag, path: path, curve: curve)
            default:
                return Promise(error: CardReaderError.invalidParameter)
            }
        }.done { key in
            cb(.success(key))
        }.catch { error in
            cb(.failure(error))
        }
    }

    func signHashPath(tag: NFCISO7816Tag, pin: String, path: String, curve: CardCurve, algorithm: CardAlgorithm,
                      hash: Data, cb: @escaping (Swift.Result<Data, Error>) -> Void) {
        firstly {
            self.selectWallet(tag: tag)
        }.then {
            self.verifyPin(tag: tag, pin: pin)
        }.then { _ in
            self.signHashPathChained(tag: tag, path: path, curve: curve, algorithm: algorithm, hash: hash)
        }.done { signedHash in
            cb(.success(signedHash))
        }.catch { error in
            cb(.failure(error))
        }
    }
    // Low level card operations

    func selectWallet(tag: NFCISO7816Tag, cardVer: CardVersion? = nil) -> Promise<Void> {
        var ver = cardVer ?? self.cardVersion ?? .card2
        return firstly {
            return doCardIO_1(tag: tag, param: ver, req: self.wallet.selectWalletRequest,
                              resp: self.wallet.selectWalletResponse)
        }.then { gotVer -> Promise<CardVersion> in
            // Check if card version we got matches what we asked for
            if gotVer != ver {
                if cardVer == nil && self.cardVersion == nil {
                    // If current card version is unknown, try to select version we got
                    if gotVer != .card1 {
                        return Promise(error: CardReaderError.invalidCard)
                    }
                    ver = gotVer
                    return self.doCardIO_1(tag: tag, param: ver, req: self.wallet.selectWalletRequest,
                                           resp: self.wallet.selectWalletResponse)
                } else {
                    // Valid card but doesn't match what we wanted
                    return Promise(error: CardReaderError.invalidCard)
                }
            } else {
                return .value(gotVer)
            }
        }.then { gotVer2 -> Promise<Void> in
            if gotVer2 != ver {
                // Still doesn't match
                return Promise(error: CardReaderError.invalidCard)
            } else {
                self.cardVersion = ver
                if ver == .card2 {
                    // Set up encrypted session
                    return self.doCardIO(tag: tag, req: self.wallet.initEncryptedSessionRequest, resp: self.wallet.initEncryptedSessionResponse)
                } else {
                    return .value
                }
            }
        }
    }

    func getGGUID(tag: NFCISO7816Tag) -> Promise<Data> {
        return doCardIO(tag: tag, req: wallet.getGGUIDRequest, resp: wallet.getGGUIDResponse)
    }

    func getFirmwareVersion(tag: NFCISO7816Tag) -> Promise<String> {
        return doCardIO(tag: tag, req: wallet.getFirmwareVersionRequest, resp: wallet.getFirmwareVersionResponse)
    }

    func storePin(tag: NFCISO7816Tag, pin: String) -> Promise<Void> {
        return doCardIO_1(tag: tag, param: pin, req: wallet.storeDataPinRequest, resp: wallet.storeDataPinResponse)
    }

    func verifyPin(tag: NFCISO7816Tag, pin: String) -> Promise<(Bool, Int)> {
        return firstly {
            doCardIO_1(tag: tag, param: pin, req: wallet.verifyPinRequest, resp: wallet.verifyPinResponse)
        }.then { (success, tries) -> Promise<(Bool, Int)> in
            if !success {
                throw CardReaderError.verifyPinFailed(tries)
            }
            return .value((success, tries))
        }
    }

    func resetWallet(tag: NFCISO7816Tag) -> Promise<Void> {
        return doCardIO(tag: tag, req: wallet.resetWalletRequest, resp: wallet.resetWalletResponse)
    }

    func createWalletSeed(tag: NFCISO7816Tag, wordCount: Int) -> Promise<[String]> {
        return doCardIO_1(tag: tag, param: wordCount, req: wallet.createWalletSeedRequest, resp: wallet.createWalletResponse)
    }

    func initRecoverWallet(tag: NFCISO7816Tag, wordCount: Int) -> Promise<Void> {
        return doCardIO_1(tag: tag, param: wordCount, req: wallet.initRecoverWalletRequest, resp: wallet.initRecoverWalletResponse)
    }

    func finishRecoverWalletSeed(tag: NFCISO7816Tag, seed: Data) -> Promise<Void> {
        return doCardIO_1(tag: tag, param: seed, req: wallet.finishRecoverWalletSeedRequest, resp: wallet.finishRecoverWalletResponse)
    }

    func signHashPath(tag: NFCISO7816Tag, path: String, curve: CardCurve, algorithm: CardAlgorithm, hash: Data) -> Promise<Data> {
        let param = (path: path, curve: curve, algorithm: algorithm, hash: hash)
        return doCardIO_1(tag: tag, param: param, req: wallet.signHashPathRequest, resp: wallet.signHashPathResponse)
    }

    func signHashPathChained(tag: NFCISO7816Tag, path: String, curve: CardCurve, algorithm: CardAlgorithm, hash: Data) -> Promise<Data> {
        let param = (path: path, curve: curve, algorithm: algorithm, hash: hash)
        return doCardIOChained(tag: tag, param: param, req: wallet.signHashPathChainedRequest, resp: wallet.signHashPathResponse)
    }

    func getPublicKeyByPathv2(tag: NFCISO7816Tag, path: String, curve: CardCurve) -> Promise<PubKey> {
        let param: (String, CardCurve) = (path, curve)
        //let param = (path: path, curve: curve)
        return doCardIO_1(tag: tag, param: param, req: wallet.getPublicKeyByPathRequest, resp: wallet.getPublicKeyByPathResponse)
    }

    // Common generic functions to call request function and receive command bytes, t	hen send the bytes to the card and
    // call response function on the result.
    // There are variations based on the API function's return value and parameters.

    // No-parameter variants
    private func doCardIO<T>(tag: NFCISO7816Tag, req: () -> Data?, resp: @escaping (Data) -> T?) -> Promise<T> {
        if let command = req() {
            return firstly {
                tag.sendCommand(command)
            }.then { response -> Promise<T> in
                guard let out = resp(response) else {
                    return Promise(error: CardReaderError.operationFailed)
                }
                return .value(out)
            }
        } else {
            return Promise(error: CardReaderError.operationFailed)
        }
    }

    private func doCardIO(tag: NFCISO7816Tag, req: () -> Data?, resp: @escaping (Data) -> Bool) -> Promise<Void> {
        if let command = req() {
            return firstly {
                tag.sendCommand(command)
            }.then { response -> Promise<Void> in
                if !resp(response) {
                    return Promise(error: CardReaderError.operationFailed)
                }
                return .value
            }
        } else {
            return Promise(error: CardReaderError.operationFailed)
        }
    }

    // Single-parameter variants
    private func doCardIO_1<T, P>(tag: NFCISO7816Tag, param: P, req: (P) -> Data?, resp: @escaping (Data) -> T?) -> Promise<T> {
        if let command = req(param) {
            return firstly {
                tag.sendCommand(command)
            }.then { response -> Promise<T> in
                guard let out = resp(response) else {
                    return Promise(error: CardReaderError.operationFailed)
                }
                return .value(out)
            }
        } else {
            return Promise(error: CardReaderError.operationFailed)
        }
    }

    private func doCardIO_1<P>(tag: NFCISO7816Tag, param: P, req: (P) -> Data?, resp: @escaping (Data) -> Bool) -> Promise<Void> {
        if let command = req(param) {
            return firstly {
                tag.sendCommand(command)
           }.then { response -> Promise<Void> in
                if !resp(response) {
                    return Promise(error: CardReaderError.operationFailed)
                }
                return .value
            }
        } else {
            return Promise(error: CardReaderError.operationFailed)
        }
    }

    private func doCardIOChained<P, R>(tag: NFCISO7816Tag, param: P, req: (P) -> [Data]?, resp: @escaping (Data) -> R?) -> Promise<R> {

        if let apdus = req(param) {
            return firstly {
                tag.sendCommandChain(apdus)
            }.then { response -> Promise<R> in
                guard let out = resp(response) else {
                    return Promise(error: CardReaderError.operationFailed)
                }
                return .value(out)
            }
        } else {
            return Promise(error: CardReaderError.operationFailed)
        }
    }

}

extension NFCISO7816Tag {
    func sendCommand(_ data: Data) -> Promise<Data> {
        guard let command = NFCISO7816APDU(data: data) else {
            return Promise(error: NFCReaderError(.readerErrorInvalidParameterLength))
        }

        return Promise { seal in
            sendCommand(apdu: command) { response, sw1, sw2, error in
                let data = response + Data([sw1]) + Data([sw2])
                guard let error = error else {
                    seal.fulfill(data)
                    return
                }

                seal.reject(error)
            }
        }
    }

    func sendCommandChain(_ apdus: [Data]) -> Promise<Data> {

        var result: Promise<Data>
        var resolver: Resolver<Data>
        (result, resolver) = Promise<Data>.pending()

        for (index, apdu) in apdus.enumerated() {
            firstly {
                sendCommand(apdu)
            }.done { data in
                if index == apdus.count - 1	{
                    // Last item return the promise...
                    resolver.fulfill(data)
                } else {
                    if data.count == 2 {
                        let sw1 = data[0]
                        let sw2 = data[1]
                        if sw1 != 0x90 && sw2 != 0x00 {
                            // Error bail
                            resolver.reject(CardReaderError.operationFailed)
                        }
                    } else {
                        resolver.reject(CardReaderError.operationFailed)
                    }
                }
            }.catch { error in
                print("Error occurred: \(error)")
                resolver.reject(error)
            }
        }
        return result
    }
}

enum CardReaderError: LocalizedError {
    case invalidParameter
    case invalidCard
    case verifyPinFailed(Int)
    case operationFailed

    var errorDescription: String? {
        switch self {
        case .invalidParameter:
            return "An invalid parameter was supplied"
        case .operationFailed:
            return "The operation couldn't be completed"
        case .invalidCard:
            return "Wrong Arculus card"
        case let .verifyPinFailed(tries):
            return "PIN-code doesn’t match. \(tries) \(tries == 1 ? "try" : "tries") remaining before lockout"
        }
    }
}
