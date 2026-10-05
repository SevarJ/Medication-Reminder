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
    @State private var detailViewModel: MedicationDetailViewModel?
    
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
                .navigationDestination(isPresented: Binding(
                    get: { detailViewModel != nil },
                    set: { if !$0 { detailViewModel = nil } }
                )) {
                    if let detailViewModel {
                        MedicationDetailView(viewModel: detailViewModel) {
                            Task { await viewModel.start() }
                        }
                    }
                }
        }
        .sheet(item: $editorViewModel) { editor in
            MedicationEditorView(
                viewModel: editor,
                onFinish: { saved in
                    editorViewModel = nil
                    
                    if saved {
                        Task { await viewModel.start() }
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
                Task { await viewModel.refresh() }
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
            calendar
            
            highlight
            
            if !viewModel.isSelectedDayLoaded {
                EmptyView()
            }
            else if viewModel.selectedDoses.isEmpty {
                Section {
                    emptyState
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }
            else if viewModel.isExpanded {
                Section {
                    Text(viewModel.fullTitle)
                        .font(Font.theme.sectionTitle)
                        .foregroundStyle(Color.theme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                }
                .listRowInsets(EdgeInsets(top: 0, leading: Spacing.sm, bottom: 0, trailing: Spacing.sm))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
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
                
                Group {
                    if viewModel.isEditable(dose) {
                        DoseRow(
                            dose: dose,
                            state: state,
                            onTake: { record(dose, as: .taken) },
                            onSkip: { record(dose, as: .skipped) },
                            onOpen: { open(dose) }
                        )
                    }
                    else {
                        HistoryDoseRow(dose: dose, state: state, onOpen: { open(dose) })
                    }
                }
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
    
    // MARK: Calendar
    
    @ViewBuilder private var calendar: some View {
        Section {
            calendarHeader
                .listRowInsets(EdgeInsets(top: 0, leading: Spacing.xs, bottom: 0, trailing: Spacing.xs))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            if !viewModel.isExpanded {
                WeekStrip(
                    days: viewModel.week,
                    isSelected: viewModel.isSelected,
                    onSelect: viewModel.select
                )
                .listRowInsets(EdgeInsets(top: 0, leading: Spacing.xs, bottom: 0, trailing: Spacing.xs))
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
        
        if viewModel.isExpanded {
            month
        }
    }
    
    private var calendarHeader: some View {
        let model = viewModel.monthCalendar
        
        return HStack(spacing: Spacing.sm) {
            if viewModel.isExpanded {
                headerButton("chevron.left", label: L10n.History.previousMonth, isEnabled: model.canShowPreviousMonth) {
                    await model.showPreviousMonth()
                }
            }
            
            Text(viewModel.calendarTitle)
                .font(Font.theme.sectionTitle)
                .foregroundStyle(Color.theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity, alignment: viewModel.isExpanded ? .center : .leading)
                .padding(.leading, viewModel.isExpanded ? 0 : Spacing.sm)
                .accessibilityAddTraits(.isHeader)
            
            if viewModel.isExpanded {
                headerButton("chevron.right", label: L10n.History.nextMonth, isEnabled: model.canShowNextMonth) {
                    await model.showNextMonth()
                }
            }
            
            Button {
                Task { await viewModel.toggleCalendar() }
            } label: {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(viewModel.isExpanded ? 180 : 0))
                    .frame(width: Size.minTarget, height: Size.minTarget)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(viewModel.isExpanded ? L10n.Today.hideCalendar : L10n.Today.showCalendar)
        }
        .font(.system(.body, weight: .semibold))
        .buttonStyle(.plain)
        .foregroundStyle(Color.theme.accentText)
        .sensoryFeedback(.selection, trigger: viewModel.monthCalendar.month)
    }
    
    private func headerButton(
        _ systemName: String,
        label: String,
        isEnabled: Bool,
        action: @escaping () async -> Void
    ) -> some View {
        Button {
            Task { await action() }
        } label: {
            Image(systemName: systemName)
                .frame(width: Size.minTarget, height: Size.minTarget)
                .contentShape(Rectangle())
        }
        .disabled(!isEnabled)
        .accessibilityLabel(label)
    }
    
    @ViewBuilder private var month: some View {
        let model = viewModel.monthCalendar
        
        switch model.state {
        case .loading:
            Section {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 160)
            }
            .listRowBackground(Color.clear)
        case .failure:
            Section {
                monthFailure
            }
            .listRowBackground(Color.clear)
        case .loaded:
            Section {
                MonthGrid(
                    weekdayHeaders: model.weekdayHeaders,
                    days: model.gridDays,
                    summary: model.summary(on:),
                    outcome: model.outcome(on:),
                    isSelected: viewModel.isSelected,
                    isEnabled: model.isSelectable,
                    onSelect: viewModel.select
                )
                .padding(.vertical, Spacing.sm)
            }
            .listRowBackground(Color.theme.surface)
            
            if !model.days.isEmpty {
                Section {
                    MonthTotalsCard(
                        adherence: model.adherence,
                        taken: model.takenCount,
                        skipped: model.skippedCount,
                        missed: model.missedCount
                    )
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
    }
    
    private var monthFailure: some View {
        VStack(spacing: Spacing.md) {
            Text(L10n.History.loadFailedTitle)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(L10n.History.loadFailedMessage)
                .font(Font.theme.rowSubtitle)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(CommonText.tryAgain) {
                Task { await viewModel.monthCalendar.reload() }
            }
            .buttonStyle(.secondaryAction)
            .fixedSize()
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.lg)
    }
    
    private func open(_ dose: ScheduledDose) {
        detailViewModel = viewModel.makeDetailViewModel(for: dose.medication)
    }
    
    private func record(_ dose: ScheduledDose, as status: DoseStatus) {
        Task { await viewModel.record(dose, as: status) }
    }
}
