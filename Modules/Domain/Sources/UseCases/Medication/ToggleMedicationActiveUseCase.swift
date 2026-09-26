//
//  ToggleMedicationActiveUseCase.swift
//  Domain
//
//  Created by Sevar Jafarli on 01.08.26.
//

public struct ToggleMedicationActiveUseCase: Sendable {
    private let saveMedication: SaveMedicationUseCase
    
    public init(saveMedication: SaveMedicationUseCase) {
        self.saveMedication = saveMedication
    }
    
    public func execute(_ medication: Medication) async throws -> Medication {
        let updatedMedication = medication.updating(isActive: !medication.isActive)
        try await saveMedication.execute(updatedMedication)
        return updatedMedication
    }
}
