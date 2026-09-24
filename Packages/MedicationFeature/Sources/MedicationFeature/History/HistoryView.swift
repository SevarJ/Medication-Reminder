//
//  HistoryView.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import DesignSystem
import Domain
import SwiftUI

public struct HistoryView: View {
    @State private var viewModel: HistoryViewModel
    
    @Environment(\.scenePhase) private var scenePhase
    
    public init(viewModel: HistoryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background)
                .navigationTitle("History")
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
        case .loaded(let summaries):
            history(for: summaries)
        case .failure(let message):
            failureState(message: message)
        }
    }
    
    private func history(for summaries: [DoseDaySummary]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                adherenceCard
                
                ForEach(summaries) { summary in
                    daySection(summary)
                }
            }
            .padding(.vertical, Spacing.lg)
        }
    }
    
    private var adherenceCard: some View {
        CardSection {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Last 7 Days")
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                
                Text(viewModel.adherence.formatted(.percent.precision(.fractionLength(0))))
                    .font(Font.theme.screenTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                ProgressView(value: viewModel.adherence)
                    .tint(Color.theme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(Spacing.lg)
        }
    }
    
    private func daySection(_ summary: DoseDaySummary) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionHeader(title: summary.date.formatted(.dateTime.weekday(.wide).day().month(.abbreviated)))
                
                Spacer()
                
                Badge(title: "\(summary.takenCount)/\(summary.doses.count)")
                    .padding(.trailing, Spacing.lg)
            }
            
            CardSection {
                ForEach(Array(summary.doses.enumerated()), id: \.element.id) { index, dose in
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
                systemName: "clock.arrow.circlepath",
                foreground: Color.theme.accent,
                background: Color.theme.accentTint
            )
            
            Text("No History Yet")
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text("Doses from the last seven days will appear here.")
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
            
            Text("Could Not Load History")
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
