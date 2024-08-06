import CoreNFC

class NFCSessionManager: NSObject, NFCTagReaderSessionDelegate {
    private var session: NFCTagReaderSession?
    
    private var continuation: CheckedContinuation<NFCISO7816Tag, Error>?
    
    enum NFCSessionManagerError: Error, LocalizedError {
        case noCompatibleTagsFound
        
        var errorDescription: String? {
            switch self {
            case .noCompatibleTagsFound: return "No compatible tags found"
            }
        }
    }
    
    func beginSession() async throws -> NFCISO7816Tag {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
            session?.alertMessage = "Hold your card to the back of your smartphone for up to a minute"
            session?.begin()
        }
    }
    
    func invalidateSession() {
        session?.invalidate()
        session = nil
    }
    
    func invalidateSession(errorMessage: String) {
        session?.invalidate(errorMessage: errorMessage)
        session = nil
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first(where: {
            if case .iso7816 = $0 { true } else { false }
        }), case .iso7816(let iso7816Tag) = tag else {
            continuation?.resume(throwing: NFCSessionManagerError.noCompatibleTagsFound)
            return
        }
        
        session.connect(to: tag) { error in
            if let error = error {
                self.continuation?.resume(throwing: error)
                return
            }
            
            self.continuation?.resume(returning: iso7816Tag)
        }
    }
    
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        continuation?.resume(throwing: error)
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {}
}
