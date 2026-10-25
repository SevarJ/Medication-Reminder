//
//  FirebaseDiagnostics.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 25.10.26.
//

internal import FirebaseAuth
internal import FirebaseCrashlytics
internal import FirebasePerformance

enum FirebaseDiagnostics {
    static func start() {
        _ = Auth.auth().addStateDidChangeListener { _, user in
            Crashlytics.crashlytics().setUserID(user?.uid)
        }
    }
}
