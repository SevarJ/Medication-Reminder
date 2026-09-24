//
//  TodayView.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import Domain
import SwiftUI

public struct TodayView: View {
    @State private var viewModel: TodayViewModel
    
    @Environment(\.scenePhase) private var scenePhase
    
    public init(viewModel: TodayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background)
                .navigationTitle("Today")
                .navigationBarTitleDisplayMode(.inline)
        }
        .alert(
            "Something Went Wrong",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.start()
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                Task { await viewModel.load() }
            }
        }
    }
    
    @ViewBuilder private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .empty:
            emptyState
        case .loaded(let doses):
            schedule(for: doses)
        case .failure(let message):
            failureState(message: message)
        }
    }
    
    private func schedule(for doses: [ScheduledDose]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                header
                
                ForEach(DosePeriod.allCases) { period in
                    let periodDoses = viewModel.doses(in: period, from: doses)
                    
                    if !periodDoses.isEmpty {
                        section(period, doses: periodDoses)
                    }
                }
            }
            .padding(.bottom, Spacing.lg)
        }
    }
    
    private var header: some View {
        Text(viewModel.title)
            .font(Font.theme.rowSubtitle)
            .foregroundStyle(Color.theme.textSecondary)
            .padding(.horizontal, Spacing.lg)
            .padding(.top, Spacing.sm)
    }
    
    private func section(_ period: DosePeriod, doses: [ScheduledDose]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: period.iconName)
                    .foregroundStyle(Color.theme.accent)
                
                SectionHeader(title: period.title)
            }
            .padding(.leading, Spacing.lg)
            
            CardSection {
                ForEach(Array(doses.enumerated()), id: \.element.id) { index, dose in
                    if index > 0 {
                        RowSeparator()
                    }
                    
                    DoseRow(
                        dose: dose,
                        state: viewModel.state(of: dose),
                        onTake: { record(dose, as: .taken) },
                        onSkip: { record(dose, as: .skipped) }
                    )
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "checkmark.circle.fill",
                foreground: Color.theme.accent,
                background: Color.theme.accentTint
            )
            
            Text("Nothing Scheduled Today")
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text("Medications scheduled for today will appear here.")
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xxl)
    }
    
    private func failureState(message: String) -> some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "exclamationmark.triangle.fill",
                foreground: Color.theme.danger,
                background: Color.theme.surface
            )
            
            Text("Could Not Load Today")
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(message)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Try Again") {
                Task { await viewModel.load() }
            }
            .font(Font.theme.rowTitle)
            .tint(Color.theme.accent)
            .padding(.top, Spacing.sm)
        }
        .padding(Spacing.xxl)
    }
    
    private func record(_ dose: ScheduledDose, as status: DoseStatus) {
        Task { await viewModel.record(dose, as: status) }
    }
}
