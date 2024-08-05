import CoreNFC
import PromiseKit

class NFCSessionManager: NSObject, NFCTagReaderSessionDelegate {
    private var resolve: RCTPromiseResolveBlock?
    private var reject: ((String, String, Error) -> Void)?
    private var command: Command?
    
    private var session: NFCTagReaderSession?
    
    func startSession(command: Command, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping (String, String, Error) -> Void) {
        self.command = command
        self.resolve = resolve
        self.reject = reject
        
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.alertMessage = "Hold your card to the back of your smartphone for up to a minute"
        session?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first(where: { if case .iso7816 = $0 { return true } else { return false } }),
              case .iso7816(let iso7816Tag) = tag else {
            session.invalidate(errorMessage: "No compatible tags found.")
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                self.reject?("NFC_READ_ERROR", "Error: card read failed", error)
                return
            }
            
            self.command?.execute(tag: iso7816Tag) { result in
                switch result {
                case .success(let response):
                    self.session?.invalidate()
                    self.resolve?(response)
                case .failure(let error):
                    self.session?.invalidate(errorMessage: error.localizedDescription)
                    self.reject?("NFC_COMMAND_ERROR", "Command execution failed", error)
                }
            }
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        if let nfcError = error as? NFCReaderError, nfcError.code != .readerSessionInvalidationErrorUserCanceled {
            reject?("NFC_SESSION_ERROR", "Session error", error)
        }
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
}
