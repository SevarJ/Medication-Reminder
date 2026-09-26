//
//  TodayView.swift
//  MedicationFeature
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import DesignSystem
import Domain
import SwiftUI

public struct TodayView: View {
    @State private var viewModel: TodayViewModel
    @State private var editorViewModel: MedicationEditorViewModel?
    
    @Environment(\.scenePhase) private var scenePhase
    
    public init(viewModel: TodayViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background)
                .navigationTitle(L10n.Today.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editorViewModel = viewModel.makeNewMedicationEditor()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(.body, weight: .semibold))
                        }
                        .tint(Color.theme.accent)
                    }
                }
        }
        .sheet(item: $editorViewModel) { editor in
            MedicationEditorView(
                viewModel: editor,
                onFinish: { saved in
                    editorViewModel = nil
                    
                    if saved {
                        Task { await viewModel.load() }
                    }
                },
                onDelete: nil
            )
        }
        .alert(
            CommonText.errorTitle,
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(CommonText.ok, role: .cancel) {}
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
        case .loaded:
            schedule
        case .failure(let message):
            failureState(message: message)
        }
    }
    
    private var schedule: some View {
        List {
            Section {
                header
                
                WeekStrip(
                    days: viewModel.week,
                    isSelected: viewModel.isSelected,
                    onSelect: viewModel.select
                )
            }
            .listRowInsets(EdgeInsets(top: Spacing.sm, leading: 0, bottom: Spacing.sm, trailing: 0))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            highlight
            
            if viewModel.selectedDoses.isEmpty {
                Section {
                    emptyState
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }
            
            ForEach(DosePeriod.allCases) { period in
                let doses = viewModel.doses(in: period)
                
                if !doses.isEmpty {
                    section(period, doses: doses)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(Spacing.lg)
        .contentMargins(.top, Spacing.sm, for: .scrollContent)
        .scrollContentBackground(.hidden)
        .animation(.spring(duration: 0.35), value: viewModel.week)
        .animation(.spring(duration: 0.35), value: viewModel.selectedDay)
        .refreshable {
            await viewModel.load()
        }
    }
    
    private var header: some View {
        HStack(spacing: Spacing.lg) {
            ProgressRing(progress: viewModel.progress, lineWidth: 10)
                .frame(width: 96, height: 96)
                .overlay {
                    VStack(spacing: 0) {
                        Text(viewModel.selectedDoses.isEmpty ? "–" : "\(viewModel.takenCount)/\(viewModel.selectedDoses.count)")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.theme.textPrimary)
                            .contentTransition(.numericText())
                        
                        Text(L10n.Today.taken)
                            .font(Font.theme.caption)
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                    .animation(.spring, value: viewModel.takenCount)
                }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(viewModel.title)
                    .font(.system(.title3, weight: .bold))
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(L10n.Today.weekAdherence(viewModel.weekAdherence.formatted(.percent.precision(.fractionLength(0)).locale(AppLanguage.current.locale))))
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.bottom, Spacing.sm)
    }
    
    @ViewBuilder private var highlight: some View {
        if let dose = viewModel.nextDose {
            Section {
                TimelineView(.everyMinute) { _ in
                    NextDoseCard(
                        dose: dose,
                        countdown: viewModel.countdown(to: dose),
                        onTake: { record(dose, as: .taken) }
                    )
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
        else if viewModel.isDayComplete {
            Section {
                DayCompleteCard()
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
        }
    }
    
    private func section(_ period: DosePeriod, doses: [ScheduledDose]) -> some View {
        Section {
            ForEach(doses) { dose in
                let state = viewModel.state(of: dose)
                
                DoseRow(
                    dose: dose,
                    state: state,
                    onTake: { record(dose, as: .taken) },
                    onSkip: { record(dose, as: .skipped) }
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(state == .taken ? Color.theme.accentTint : Color.theme.surface)
                .listRowSeparatorTint(Color.theme.separator)
            }
        } header: {
            Label(period.title, systemImage: period.iconName)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .textCase(nil)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "checkmark.circle.fill",
                foreground: Color.theme.accent,
                background: Color.theme.accentTint
            )
            
            Text(viewModel.isTodaySelected ? L10n.Today.emptyTitle : L10n.Today.emptyDayTitle)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            if viewModel.isTodaySelected {
                Text(L10n.Today.emptyMessage)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
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
            
            Text(L10n.Today.loadFailedTitle)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(message)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(CommonText.tryAgain) {
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
