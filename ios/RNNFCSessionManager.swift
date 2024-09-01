import CoreNFC
import React

class RNNFCSessionManager : NFCSessionManager, NFCTagReaderSessionDelegate {
    private var continuation: CheckedContinuation<NFCISO7816Tag, Error>?
    private let semaphore = DispatchSemaphore(value: 1)
    private let eventEmitter: RCTEventEmitter
    
    init(eventEmitter: RCTEventEmitter) {
        self.eventEmitter = eventEmitter
    }
    
    override func getTag() async throws -> NFCISO7816Tag {
        return try await withCheckedThrowingContinuation { continuation in
            let _ = semaphore.wait(timeout: .now() + 1)
            
            if let continuation = self.continuation {
                continuation.resume(throwing: NFCSessionManagerError.sessionOverlap)
            }
            
            self.continuation = continuation
            
            startScanning(delegate: self)
        }
    }
    
    override func close() {
        semaphore.signal()
        
        super.close()
        
        eventEmitter.sendEvent(withName: "ConnectionClosed", body: nil)
    }
    
    override func done() {
        semaphore.signal()
        
        super.done()
        
        close()
    }
    
    override func fail(errorMessage: String) {
        semaphore.signal()
        
        super.fail(errorMessage: errorMessage)
        
        close()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: any Error) {
        if let continuation = continuation {
            continuation.resume(throwing: error)
            
            self.continuation = nil
        }
        
        close()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        handleTagDetection(tags: tags) { result in
            switch result {
            case let .failure(error):
                self.continuation?.resume(throwing: error)
            case let .success(tag):
                self.continuation?.resume(returning: tag)
                
                self.eventEmitter.sendEvent(withName: "ConnectionOpened", body: nil)
            }
            self.continuation = nil
        }
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        eventEmitter.sendEvent(withName: "ScanningStarted", body: nil)
    }
}
