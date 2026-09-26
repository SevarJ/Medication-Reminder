//
//  MedTimeRecord.swift
//  Persistence
//
//  Created by Sevar Jafarli on 01.08.26.
//

import Foundation

struct MedTimeRecord: Codable, Hashable {
    let id: UUID
    let hour: Int
    let minute: Int
}
