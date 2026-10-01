//
//  FirestoreDocumentError.swift
//  FirebaseKit
//
//  Created by Sevar Jafarli on 01.10.26.
//

enum FirestoreDocumentError: Error, Equatable {
    case invalidIdentifier(String)
    case unknownDosageUnit(String)
    case unknownRecurrence(String)
    case unknownDoseStatus(String)
}
