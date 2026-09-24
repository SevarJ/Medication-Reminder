//
//  HistoryViewModel.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import Domain
import Foundation
import Observation

@MainActor
@Observable
public final class HistoryViewModel {
    private(set) var state: HistoryState = .loading
    var errorMessage: String?
    
    private let loadHistory: LoadDoseHistoryUseCase
    private let recordDose: RecordDoseUseCase
    private let currentDate: @Sendable () -> Date
    
    public init(
        loadHistory: LoadDoseHistoryUseCase,
        recordDose: RecordDoseUseCase,
        currentDate: @escaping @Sendable () -> Date = { .now }
    ) {
        self.loadHistory = loadHistory
        self.recordDose = recordDose
        self.currentDate = currentDate
    }
    
    public func start() async {
        await load()
    }
    
    func load() async {
        switch state {
        case .loaded, .empty:
            break
        case .loading, .failure:
            state = .loading
        }
        
        do {
            let summaries = try await loadHistory.execute(endingOn: currentDate())
            
            state = summaries.isEmpty ? .empty : .loaded(summaries)
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
    
    var adherence: Double {
        guard case .loaded(let summaries) = state else { return 0 }
        
        let doses = summaries.flatMap { $0.doses }
        
        guard !doses.isEmpty else { return 0 }
        
        return Double(doses.count { $0.log?.status == .taken }) / Double(doses.count)
    }
    
    private func replace(_ dose: ScheduledDose) {
        guard case .loaded(let summaries) = state else { return }
        
        state = .loaded(
            summaries.map { summary in
                guard summary.doses.contains(where: { $0.id == dose.id }) else { return summary }
                
                return DoseDaySummary(
                    date: summary.date,
                    doses: summary.doses.map { $0.id == dose.id ? dose : $0 }
                )
            }
        )
    }
}
