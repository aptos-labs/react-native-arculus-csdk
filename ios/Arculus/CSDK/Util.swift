/// Converts a `Data` object into a hexadecimal string prefixed with "0x".
///
/// This function takes a `Data` object and converts each byte into its
/// corresponding two-character hexadecimal representation, then concatenates
/// these hex values into a single string. The string is prefixed with "0x"
/// to indicate it's a hexadecimal value.
///
/// - Parameter data: The `Data` object to be converted.
/// - Returns: A `String` representing the hexadecimal value of the data, with a "0x" prefix.
///
/// # Example
/// ```swift
/// let data = Data([0x12, 0x34, 0xAB, 0xCD])
/// let hexString = dataToHexString(data)
/// print(hexString) // Prints "0x1234abcd"
/// ```
public func dataToHexString(_ data: Data) -> String {
    return "0x" + data.map { String(format: "%02x", $0) }.joined()
}

enum HexStringToDataError: Error, LocalizedError {
    case oddLength
    case invalidCharacters(String)
    
    var localizedDescription: String {
        switch self {
        case .oddLength:
            return "The input string must have an even number of characters"
        case .invalidCharacters(let characters):
            return "The input string contains invalid characters: \(characters)"
        }
    }
}

public func hexStringToData(_ hexString: String) throws -> Data {
    let hex = hexString.hasPrefix("0x") ? String(hexString.dropFirst(2)) : hexString
    
    guard hex.count % 2 == 0 else { throw HexStringToDataError.oddLength }
    
    var capacity = hex.count / 2
    
    var data = Data(capacity: capacity)
    
    var index = hex.startIndex
    
    for _ in 0..<capacity {
        let nextIndex = hex.index(index, offsetBy: 2)
        
        let byteString = String(hex[index..<nextIndex])
        
        if let num = UInt8(byteString, radix: 16) {
            data.append(num)
        } else {
            throw HexStringToDataError.invalidCharacters(byteString)
        }
        
        index = nextIndex
    }
    return data
}
