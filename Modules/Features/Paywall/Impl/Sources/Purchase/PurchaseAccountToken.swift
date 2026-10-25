//
//  PurchaseAccountToken.swift
//  PaywallImpl
//
//  Created by Sevar Jafarli on 25.10.26.
//

import CryptoKit
import Foundation

enum PurchaseAccountToken {
    static let medoraNamespace = UUID(uuidString: "901FFC4F-7C92-4B28-87B2-948212AB8C84")!

    static func make(for accountID: String, in namespace: UUID = medoraNamespace) -> UUID {
        let namespaceBytes = withUnsafeBytes(of: namespace.uuid) { Array($0) }
        var bytes = Array(Insecure.SHA1.hash(data: namespaceBytes + Array(accountID.utf8)).prefix(16))

        bytes[6] = (bytes[6] & 0x0F) | 0x50
        bytes[8] = (bytes[8] & 0x3F) | 0x80

        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }
}
