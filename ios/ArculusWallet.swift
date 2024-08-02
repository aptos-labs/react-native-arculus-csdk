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

import CSDK
import Foundation

public struct PubKey {
    public var publicKey: Data
    public var chainCode: Data

    init?(_ extk: ExtendedKey) {
        var ext = extk
        guard let pk = cArrayToData(val: &ext.publicKey, len: ext.pubKeyLe),
              let cc = cArrayToData(val: &ext.chainCodeKey, len: ext.chainCodeLe) else {
            return nil
        }
        publicKey = pk
        chainCode = cc
    }
}

public enum CardVersion: String, CaseIterable {
    case card1
    case card2

    public var aid: [UInt8] {
        switch self {
        case .card1: return [0x4a, 0x4e, 0x45, 0x54, 0x5f, 0x4c, 0x5f, 0x01, 0x01, 0x57]
        case .card2: return [0x41, 0x52, 0x43, 0x55, 0x4C, 0x55, 0x53, 0x01, 0x01, 0x57]
        }
    }
}

public enum CardCurve: UInt16, CaseIterable {
    case secp256k1 = 0x0100
    case ed25519 = 0x0201
    case ed25519Blake2bNano = 0x0202
    case ed25519Curve = 0x0203
    case nist256p1 = 0x0301
    case ed25519ExtendedCardano = 0x0401
    case sr25519 = 0x0501
    
    var val: UInt16 {
        return self.rawValue
    }
    
    var name: String {
        return String(describing: self)
    }
    
    static var allNames: [String] {
        return allCases.map {String(describing:$0)}
    }
    
}

public func getCurveFromString(curveString: String) -> CardCurve {
    switch curveString {
    case "secp256k1":
        return CardCurve.secp256k1
    case "ed25519":
        return CardCurve.ed25519
    case "ed25519Blake2bNano":
        return CardCurve.ed25519Blake2bNano
    case "ed25519Curve":
        return CardCurve.ed25519Curve
    case "nist256p1":
        return CardCurve.nist256p1
    case "ed25519ExtendedCardano":
        return CardCurve.ed25519ExtendedCardano
    case "sr25519":
        return CardCurve.sr25519
    default:
        return CardCurve.secp256k1
    }
}

public enum CardAlgorithm: UInt8, CaseIterable {
    case ecdsa = 1
    case eddsa = 2
    case schnorr = 3
    case ristretto = 4
    case cardano = 5
    
    var val: UInt8 {
        return self.rawValue
    }
    
    var name: String {
        return String(describing: self)
    }

    static var allNames: [String] {
        return allCases.map {String(describing:$0)}
    }
}

public func getHashAlgorithmFromString(hashAlgorithmString: String) -> CardAlgorithm {
    switch hashAlgorithmString {
    case "ecdsa":
        return CardAlgorithm.ecdsa
    case "eddsa":
        return CardAlgorithm.eddsa
    case "schnorr":
        return CardAlgorithm.schnorr
    case "ristretto":
        return CardAlgorithm.ristretto
    case "cardano":
        return CardAlgorithm.cardano
    default:
        return CardAlgorithm.ecdsa
    }
}


// Utility functions for data conversion from C

private func cArrayToData<T>(val: inout T, len: size_t) -> Data? {
    return withUnsafeBytes(of: val) { (rawPtr) -> Data? in
        guard let baseAddr = rawPtr.baseAddress else { return Data() }
        let ptr = baseAddr.assumingMemoryBound(to: UInt8.self)
        return Data(bytes: ptr, count: len)
    }
}

private func cApduSequenceToData(buf: UnsafePointer<APDUSequence>?) -> [Data]? {
    if let buf = buf {
        // Need to loop through all the ByteVectors in APDUSequence
        let apduSequence = buf.pointee
        let count = apduSequence.count
        let byteVectorArrayPtr = apduSequence.apdu
        if let byteVectorArrayPtr = byteVectorArrayPtr {
            var dataArray = [Data](repeating: Data(), count: Int(count))
            let byteVectorPointer = UnsafeMutablePointer<ByteVector>(byteVectorArrayPtr)

            for i in 0..<count {
                let byteVector = byteVectorPointer[Int(i)]
                // Access the fields of each ByteVector element
                let vectorData = byteVector.addr
                let vectorLength = byteVector.count
                guard let data = cBufToData(buf: vectorData, len: Int(vectorLength)) else { return nil }
                dataArray[Int(i)]=data
            }
            return dataArray
        }
    }
    return nil
}

private func cArrayToString<T>(val: inout T, len: size_t) -> String? {
    let dat = cArrayToData(val: &val, len: len)
    if let data = dat {
        return String(data: data, encoding: .utf8)
    } else {
        return nil
    }
}

private func cBufToData(buf: UnsafePointer<UInt8>?, len: Int) -> Data? {
    if let buf = buf {
        return Data(bytes: buf, count: len)
    } else {
        return nil
    }
}

private func dataToArray(_ data: Data) -> [UInt8] {
    return [UInt8](data)
}

public class ArculusWallet {

    let wallet: OpaquePointer

    // Initialization

    public init() {
        wallet = WalletInit()
    }

    deinit {
        WalletFree(wallet)
    }

    // Wallet Lifecycle

    public func walletSeedFromWords(words: [String]) -> Data? {
        var len: size_t = 0
        var str: [UInt8] = words.compactMap({ Array($0.utf8) + Array(" ".utf8) }).flatMap({ $0 })
        str.removeLast()
        guard let pointer = WalletSeedFromMnemonicSentence(wallet, str, str.count, nil, 0, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func initRecoverWalletRequest(wordCount: Int) -> Data? {
        var len: size_t = 0
        guard let pointer = WalletInitRecoverWalletRequest(wallet, wordCount, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func initRecoverWalletResponse(_ response: Data) -> Void? {
        let array = dataToArray(response)
        let result = WalletInitRecoverWalletResponse(wallet, array, array.count)
        return result == CSDK_OK ? () : nil
    }

    public func finishRecoverWalletSeedRequest(seed: Data) -> Data? {
        if seed.isEmpty { return nil }
        var len: size_t = 0
        let seedArr = dataToArray(seed)
        guard let pointer = WalletSeedFinishRecoverWalletRequest(wallet, seedArr, seedArr.count, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func finishRecoverWalletResponse(_ response: Data) -> Void? {
        let array = dataToArray(response)
        let result = WalletSeedFinishRecoverWalletResponse(wallet, array, array.count)
        return result == CSDK_OK ? () : nil
    }

    public func selectWalletRequest() -> Data? {
        return selectWalletRequest(cardVersion: .card1)
    }

    public func selectWalletRequest(cardVersion: CardVersion?) -> Data? {
        var len: size_t = 0
        let aid = cardVersion?.aid ?? CardVersion.card1.aid
        guard let pointer = WalletSelectWalletRequest(wallet, aid, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func selectWalletResponse(_ response: Data) -> CardVersion? {
        let array = dataToArray(response)
        guard let result = WalletSelectWalletResponse(wallet, array, array.count),
              case let len = size_t(min(WALLET_AID_LEN, result.pointee.ApplicationAIDLength)),
              let dat = cBufToData(buf: result.pointee.ApplicationAID, len: len)
        else { return nil }

        let aid = dataToArray(dat)
        for ver in CardVersion.allCases where aid == ver.aid {
            return ver
        }
        return nil
    }

    public func createWalletSeedRequest(wordCount: Int) -> Data? {
        var len: size_t = 0
        guard let pointer = WalletSeedCreateWalletRequest(wallet, &len, wordCount) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func createWalletResponse(_ response: Data) -> [String]? {
        let array = dataToArray(response)
        var len: size_t = 0
        guard let pointer = WalletSeedCreateWalletResponse(wallet, array, array.count, &len) else {
            return nil
        }
        if let data = cBufToData(buf: pointer, len: len),
           let str = String(data: data, encoding: .utf8) {
            return str.split(separator: " ").map({ String($0) })
        } else {
            return nil
        }
    }

    public func resetWalletRequest() -> Data? {
        var len: size_t = 0
        guard let pointer = WalletResetWalletRequest(wallet, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func resetWalletResponse(_ response: Data) -> Void? {
        let array = dataToArray(response)
        let result = WalletResetWalletResponse(wallet, array, array.count)
        return result == CSDK_OK ? () : nil
    }

    // Get Card GGUID

    public func getGGUIDRequest() -> Data? {
        var len: size_t = 0
        guard let pointer = WalletGetGGUIDRequest(wallet, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func getGGUIDResponse(response: Data) -> Data? {
        let array = dataToArray(response)
        var len: size_t = 0
        guard let pointer = WalletGetGGUIDResponse(wallet, array, array.count, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    // Get Firmware Version

    public func getFirmwareVersionRequest() -> Data? {
        var len: size_t = 0
        guard let pointer = WalletGetFirmwareVersionRequest(wallet, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func getFirmwareVersionResponse(response: Data) -> String? {
        let array = dataToArray(response)
        var len: size_t = 0
        guard let pointer = WalletGetFirmwareVersionResponse(wallet, array, array.count, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)?.map({ "\($0)" }).joined(separator: ".")
    }

    // Receive Keys

    public func getPublicKeyByPathRequest(path: String, curve: CardCurve) -> Data? {
        var len: size_t = 0
        let path: [UInt8] = Array(path.utf8)
        let unsafePath = UnsafeMutablePointer<UInt8>.allocate(capacity: path.count)
        unsafePath.assign(from: path, count: path.count)
        defer { unsafePath.deallocate() }
        guard let pointer = WalletGetPublicKeyFromPathRequest(wallet, unsafePath, path.count,curve.val, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func getPublicKeyByPathResponse(_ response: Data) -> PubKey? {
        let array = dataToArray(response)
        guard let extKey = WalletGetPublicKeyFromPathResponse(wallet, array, array.count) else {
            return nil
        }
        return PubKey(extKey.pointee)
    }


 
    // PIN Functions

    public func storeDataPinRequest(_ pin: String) -> Data? {
        var len: size_t = 0
        guard let pointer = WalletStoreDataPINRequest(wallet, pin, pin.count, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func storeDataPinResponse(_ response: Data) -> Void? {
        let array = dataToArray(response)
        let success = WalletStoreDataPINResponse(wallet, array, array.count)
        return success == CSDK_OK ? () : nil
    }

    public func verifyPinRequest(_ pin: String) -> Data? {
        var len: size_t = 0
        guard let result = WalletVerifyPINRequest(wallet, pin, pin.count, &len) else {
            return nil
        }
        return cBufToData(buf: result, len: len)
    }

    public func verifyPinResponse(_ response: Data) -> (Bool, Int)? {
        let array = dataToArray(response)
        var tries: size_t = 0
        let code = WalletVerifyPINResponse(wallet, array, array.count, &tries)
        return (code == CSDK_OK, tries)
    }

    public func signHashPathRequest(path: String, curve: CardCurve, algorithm: CardAlgorithm, hash: Data) -> Data? {
        var len: size_t = 0
        let array = dataToArray(hash)
        let path2 = path.data(using: .ascii)
        if path2 == nil {
            print("Path could not be converted to ascii, invalid chars in path")
            return nil
        }
        let pathBytes = [UInt8](path2!)
        let unsafePath = UnsafeMutablePointer<UInt8>.allocate(capacity: path2!.count)
        unsafePath.assign(from: path, count: path.count)
        defer { unsafePath.deallocate() }
        let curveInt = curve.rawValue
        let hashAlgorithm = algorithm.rawValue
        guard let pointer = WalletSignHashRequest(wallet, unsafePath, path.count, curveInt,
                                                  hashAlgorithm, array, array.count, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func signHashPathChainedRequest(path: String, curve: CardCurve, algorithm: CardAlgorithm, hash: Data) -> [Data]? {
        let hashDataArray = dataToArray(hash)
        let path2: [UInt8] = Array(path.utf8)

        var unsafePath = ByteVector(count:UInt32(path2.count), addr: UnsafeMutablePointer<UInt8>.allocate(capacity: path2.count))
        unsafePath.addr.update(from: path2, count: path2.count)
        var hashData = ByteVector(count:UInt32(hash.count), addr: UnsafeMutablePointer<UInt8>.allocate(capacity: hash.count))
        hashData.addr.update(from: hashDataArray, count: hashDataArray.count)
        var requestApduPtrPtr : UnsafeMutablePointer<UnsafeMutablePointer<APDUSequence>?>!
        requestApduPtrPtr = UnsafeMutablePointer<UnsafeMutablePointer<APDUSequence>?>.allocate(capacity: 1)

        let result = WalletSignRequest(wallet, &unsafePath, curve.val, algorithm.val, &hashData, requestApduPtrPtr)
        if result != CSDK_OK {
            return nil
        }
        let pointer = requestApduPtrPtr.pointee
        return cApduSequenceToData(buf: pointer)
    }

    public func signHashPathResponse(_ response: Data) -> Data? {
         var len: size_t = 0
         let array = dataToArray(response)
         guard let pointer = WalletSignHashResponse(wallet, array, array.count, &len) else {
             return nil
         }
         return cBufToData(buf: pointer, len: len)
     }
    
    public func initEncryptedSessionRequest() -> Data? {
        var len: size_t = 0
        guard let pointer = WalletInitSessionRequest(wallet, &len) else {
            return nil
        }
        return cBufToData(buf: pointer, len: len)
    }

    public func initEncryptedSessionResponse(_ response: Data) -> Void? {
        let array = dataToArray(response)
        let result = WalletInitSessionResponse(wallet, array, array.count)
        return result == CSDK_OK ? () : nil
    }

}
