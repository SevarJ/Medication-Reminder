//
//  TodayView.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 24.09.26.
//

import AppLocalization
import DesignSystem
import Domain
import SwiftUI

struct TodayView: View {
    @State private var viewModel: TodayViewModel
    @State private var editorViewModel: MedicationEditorViewModel?
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var periodIconWidth: CGFloat = 28
    
    private let reloadToken: Int
    
    init(viewModel: TodayViewModel, reloadToken: Int = 0) {
        _viewModel = State(initialValue: viewModel)
        self.reloadToken = reloadToken
    }
    
    var body: some View {
        NavigationStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.theme.background)
                .navigationTitle(L10n.Today.title)
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            editorViewModel = viewModel.makeNewMedicationEditor()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(.body, weight: .semibold))
                        }
                        .tint(Color.theme.accentText)
                        .accessibilityLabel(L10n.List.addMedication)
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
                }
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
        .onChange(of: reloadToken) {
            Task { await viewModel.start() }
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
                WeekStrip(
                    days: viewModel.week,
                    isSelected: viewModel.isSelected,
                    onSelect: viewModel.select
                )
            }
            .listRowInsets(EdgeInsets(top: 0, leading: Spacing.xs, bottom: 0, trailing: Spacing.xs))
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
            else {
                Section {
                    summary
                }
                .listRowInsets(EdgeInsets())
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
        .listSectionSpacing(Spacing.xl)
        .scrollContentBackground(.hidden)
        .animation(.spring(duration: 0.35), value: viewModel.week)
        .animation(.spring(duration: 0.35), value: viewModel.selectedDay)
        .refreshable {
            await viewModel.load()
        }
    }
    
    private var summary: some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: Spacing.md))
            : AnyLayout(HStackLayout(spacing: Spacing.lg))
        
        return layout {
            ProgressRing(progress: viewModel.progress, lineWidth: 8)
                .frame(width: 64, height: 64)
                .overlay {
                    Text("\(Int((viewModel.progress * 100).rounded()))%")
                        .font(.system(.footnote, design: .rounded, weight: .bold))
                        .dynamicTypeSize(...DynamicTypeSize.xLarge)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .foregroundStyle(Color.theme.textPrimary)
                        .contentTransition(.numericText())
                        .padding(.horizontal, Spacing.sm)
                }
            
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(viewModel.title)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                
                Text("\(viewModel.takenCount)/\(viewModel.selectedDoses.count) \(L10n.Today.taken)")
                    .font(Font.theme.sectionTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .contentTransition(.numericText())
                
                Text(L10n.Today.weekAdherence(viewModel.weekAdherence.formatted(.percent.precision(.fractionLength(0)).locale(AppLanguage.current.locale))))
                    .font(Font.theme.caption)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .animation(.spring, value: viewModel.takenCount)
            
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .cardSurface()
        .accessibilityElement(children: .combine)
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
                .listRowBackground(Color.theme.surface)
                .listRowSeparatorTint(Color.theme.separator)
            }
        } header: {
            HStack(spacing: Spacing.sm) {
                Image(systemName: period.iconName)
                    .foregroundStyle(Color.theme.textSecondary)
                    .frame(width: periodIconWidth)
                
                Text(period.title)
                    .foregroundStyle(Color.theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                
                Spacer()
                
                Text("\(doses.count { viewModel.state(of: $0) == .taken })/\(doses.count)")
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .monospacedDigit()
            }
            .font(Font.theme.sectionTitle)
            .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            .textCase(nil)
            .padding(.top, Spacing.xs)
            .accessibilityElement(children: .combine)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "checkmark.circle.fill",
                foreground: Color.theme.accentText,
                background: Color.theme.accentTint,
                size: 56
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
                foreground: Color.theme.warning,
                background: Color.theme.warningTint,
                size: 56
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
            .buttonStyle(.secondaryAction)
            .fixedSize()
            .padding(.top, Spacing.sm)
        }
        .padding(Spacing.xxl)
    }
    
    private func record(_ dose: ScheduledDose, as status: DoseStatus) {
        Task { await viewModel.record(dose, as: status) }
    }
}
