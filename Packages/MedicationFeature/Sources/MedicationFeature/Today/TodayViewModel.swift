//
//  TodayViewModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class TodayViewModel {
    private(set) var state: TodayState = .loading
    var errorMessage: String?
    
    private let loadDoses: LoadDosesUseCase
    private let recordDose: RecordDoseUseCase
    private let currentDate: @Sendable () -> Date
    
    public init(
        loadDoses: LoadDosesUseCase,
        recordDose: RecordDoseUseCase,
        currentDate: @escaping @Sendable () -> Date = { .now }
    ) {
        self.loadDoses = loadDoses
        self.recordDose = recordDose
        self.currentDate = currentDate
    }
    
    public func start() async {
        await load()
    }
    
    var title: String {
        currentDate().formatted(.dateTime.weekday(.wide).day().month(.abbreviated))
    }
    
    func load() async {
        switch state {
        case .loaded, .empty:
            break
        case .loading, .failure:
            state = .loading
        }
        
        do {
            let doses = try await loadDoses.execute(on: currentDate())
            
            state = doses.isEmpty ? .empty : .loaded(doses)
        }
        catch {
            state = .failure(message: message(for: error))
        }
    }
    
    func record(_ dose: ScheduledDose, as status: DoseStatus) async {
        do {
            replace(try await recordDose.execute(dose, status: status, now: currentDate()))
        }
        catch {
            errorMessage = message(for: error)
        }
    }
    
    func state(of dose: ScheduledDose) -> DoseState {
        dose.state(at: currentDate())
    }
    
    func doses(in period: DosePeriod, from doses: [ScheduledDose]) -> [ScheduledDose] {
        doses.filter { DosePeriod.of($0.scheduledDate) == period }
    }
    
    private func replace(_ dose: ScheduledDose) {
        guard case .loaded(var doses) = state,
              let index = doses.firstIndex(where: { $0.id == dose.id })
        else {
            return
        }
        
        doses[index] = dose
        state = .loaded(doses)
    }
}
