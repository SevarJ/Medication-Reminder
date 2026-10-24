//
//  NetworkErrors.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 24.10.26.
//

import Domain
internal import FirebaseAuth
internal import FirebaseFirestore
import Foundation

enum NetworkErrors {
    private static let appAuthDomain = "org.openid.appauth.general"
    private static let appAuthNetworkCode = -5

    private static let offlineURLCodes: Set<Int> = [
        NSURLErrorNotConnectedToInternet,
        NSURLErrorNetworkConnectionLost,
        NSURLErrorTimedOut,
        NSURLErrorCannotFindHost,
        NSURLErrorCannotConnectToHost,
        NSURLErrorDNSLookupFailed,
        NSURLErrorDataNotAllowed,
        NSURLErrorInternationalRoamingOff
    ]

    static func map(_ error: Error) -> Error {
        isOffline(error) ? ConnectionError.offline : error
    }

    static func isOffline(_ error: Error) -> Bool {
        let error = error as NSError

        switch error.domain {
        case NSURLErrorDomain where offlineURLCodes.contains(error.code),
             AuthErrors.domain where error.code == AuthErrorCode.networkError.rawValue,
             FirestoreErrorDomain where error.code == FirestoreErrorCode.unavailable.rawValue,
             appAuthDomain where error.code == appAuthNetworkCode:
            return true
        default:
            break
        }

        guard let underlying = error.userInfo[NSUnderlyingErrorKey] as? Error else { return false }

        return isOffline(underlying)
    }
}
