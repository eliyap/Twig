//
//  File.swift
//  
//
//  Created by Secret Asian Man Dev on 16/10/21.
//

import Foundation
import CommonCrypto

internal extension String {
    /// Source: https://stackoverflow.com/a/41965688/12395667
    /// Returns the HMAC-SHA256 Signature signed with `key`.
    func sha256(with key: String) -> String {
        /// Using HMAC-SHA256
        let algorithm: CCHmacAlgorithm = CCHmacAlgorithm(kCCHmacAlgSHA256)
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        
        /// Convert to C-strings.
        let cKey = key.cString(using: String.Encoding.utf8)
        let cData = self.cString(using: String.Encoding.utf8)
        
        /// Buffer in which to place hashed result.
        var result: [CUnsignedChar] = [CUnsignedChar](repeating: 0, count: digestLength)
        
        /// Hash data.
        CCHmac(algorithm, cKey!, strlen(cKey!), cData, strlen(cData!), &result)
        let hmacData: NSData = NSData(bytes: result, length: digestLength)
        let hmacBase64 = hmacData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength76Characters)
        return String(hmacBase64)
    }
}
