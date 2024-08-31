import CoreNFC

class NFCSessionManager: NSObject {
    private var session: NFCTagReaderSession?
    
    enum NFCSessionManagerError: Error, LocalizedError {
        case noCompatibleTagsFound
        case sessionOverlap
        
        var errorDescription: String? {
            switch self {
            case .noCompatibleTagsFound: return "No compatible tags found"
            case .sessionOverlap: return "Another session initilized"
            }
        }
    }
    
    func setSessionAlertMessage(message: String) {
        session?.alertMessage = message
    }
    
    func getTag() async throws -> NFCISO7816Tag {
        fatalError("getTag must be overridden")
    }
    
    func close() {
        session = nil
    }
    
    func done() {
        session?.invalidate()
    }
    
    func fail(errorMessage: String) {
        session?.invalidate(errorMessage: errorMessage)
    }
    
    func startScanning(delegate: any NFCTagReaderSessionDelegate) {
        if let session = session {
            session.restartPolling()
        } else {
            session = NFCTagReaderSession(pollingOption: .iso14443, delegate: delegate)
            session?.alertMessage = "Hold your card to the back of your smartphone for up to a minute"
            session?.begin()
        }
    }
    
    func handleTagDetection(tags: [NFCTag], completion: @escaping (Result<NFCISO7816Tag, Error>) -> Void) {
        guard let tag = tags.first(where: {
            if case .iso7816 = $0 { true } else { false }
        }), case .iso7816(let iso7816Tag) = tag else {
            completion(.failure(NFCSessionManagerError.noCompatibleTagsFound))
            return
        }
        
        session?.connect(to: tag) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(iso7816Tag))
        }
    }
}
