import CSDK

class CSDKAPICommand<T> {
    public typealias ResponseType = T

    var wallet: OpaquePointer?

    init(wallet: OpaquePointer) {
        self.wallet = wallet
    }

    func execute() async throws -> ResponseType {
        fatalError("execute func must be overridden")
    }
}
