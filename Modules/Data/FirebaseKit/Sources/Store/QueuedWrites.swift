//
//  QueuedWrites.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

internal import FirebaseFirestore

// Firestore applies a write to its offline copy at once and sends it when there is a connection.
// The `async` overloads wait for the server's answer, which never comes offline, and Swift picks them inside
// an `async` function. These wrappers are synchronous so that the queueing overloads are the ones called.

extension DocumentReference {
    func queueDelete() {
        delete()
    }
}

extension WriteBatch {
    func queueCommit() {
        commit()
    }
}
