//
//  HistoryView.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 05.10.26.
//

import AppLocalization
import DesignSystem
import Domain
import SwiftUI

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel
    
    private let reloadToken: Int
    
    init(viewModel: HistoryViewModel, reloadToken: Int = 0) {
        _viewModel = State(initialValue: viewModel)
        self.reloadToken = reloadToken
    }
    
    var body: some View {
        NavigationStack {
            List {
                monthHeader
                
                switch viewModel.state {
                case .loading:
                    loadingRow
                case .loaded:
                    loaded
                case .failure:
                    failureRow
                }
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(Spacing.xl)
            .scrollContentBackground(.hidden)
            .background(Color.theme.background)
            .navigationTitle(L10n.History.title)
            .navigationBarTitleDisplayMode(.large)
            .animation(.spring(duration: 0.35), value: viewModel.selectedDay)
            .refreshable {
                await viewModel.reload()
            }
        }
        .task {
            await viewModel.load()
        }
        .onChange(of: reloadToken) {
            Task { await viewModel.reload() }
        }
    }
    
    // MARK: Header
    
    private var monthHeader: some View {
        Section {
            HStack(spacing: Spacing.sm) {
                Button {
                    Task { await viewModel.showPreviousMonth() }
                } label: {
                    Image(systemName: "chevron.left")
                        .frame(width: Size.minTarget, height: Size.minTarget)
                        .contentShape(Rectangle())
                }
                .disabled(!viewModel.canShowPreviousMonth)
                .accessibilityLabel(L10n.History.previousMonth)
                
                Text(viewModel.title)
                    .font(Font.theme.sectionTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .frame(maxWidth: .infinity)
                    .accessibilityAddTraits(.isHeader)
                
                Button {
                    Task { await viewModel.showNextMonth() }
                } label: {
                    Image(systemName: "chevron.right")
                        .frame(width: Size.minTarget, height: Size.minTarget)
                        .contentShape(Rectangle())
                }
                .disabled(!viewModel.canShowNextMonth)
                .accessibilityLabel(L10n.History.nextMonth)
            }
            .font(.system(.body, weight: .semibold))
            .buttonStyle(.plain)
            .foregroundStyle(Color.theme.accentText)
            .sensoryFeedback(.selection, trigger: viewModel.month)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: Spacing.xs, bottom: 0, trailing: Spacing.xs))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    // MARK: Loaded
    
    @ViewBuilder private var loaded: some View {
        Section {
            MonthGrid(
                weekdayHeaders: viewModel.weekdayHeaders,
                days: viewModel.gridDays,
                summary: viewModel.summary(on:),
                outcome: viewModel.outcome(on:),
                isSelected: viewModel.isSelected,
                isEnabled: viewModel.isSelectable,
                onSelect: viewModel.select
            )
            .padding(.vertical, Spacing.sm)
            .listRowBackground(Color.theme.surface)
        }
        
        if viewModel.days.isEmpty {
            Section {
                emptyMonth
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
        }
        else {
            Section {
                totals
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        }
        
        if let title = viewModel.selectedTitle, !viewModel.selectedDoses.isEmpty {
            Section {
                ForEach(viewModel.selectedDoses) { dose in
                    HistoryDoseRow(dose: dose, state: viewModel.state(of: dose))
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.theme.surface)
                        .listRowSeparatorTint(Color.theme.separator)
                }
            } header: {
                Text(title)
                    .font(Font.theme.sectionTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .textCase(nil)
                    .dynamicTypeSize(...DynamicTypeSize.accessibility2)
            }
        }
    }
    
    private var totals: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text(
                viewModel.adherence.map {
                    L10n.History.adherence($0.formatted(.percent.precision(.fractionLength(0)).locale(AppLanguage.current.locale)))
                } ?? L10n.History.noDosesDue
            )
            .font(Font.theme.sectionTitle)
            .foregroundStyle(Color.theme.textPrimary)
            .contentTransition(.numericText())
            
            HStack(spacing: Spacing.sm) {
                Badge(title: "\(viewModel.takenCount) \(L10n.History.taken)", systemName: "checkmark")
                Badge(
                    title: "\(viewModel.skippedCount) \(L10n.Today.skipped)",
                    systemName: "forward.end.fill",
                    foreground: Color.theme.info,
                    background: Color.theme.infoTint
                )
                Badge(
                    title: "\(viewModel.missedCount) \(L10n.Today.missed)",
                    systemName: "exclamationmark",
                    foreground: Color.theme.warning,
                    background: Color.theme.warningTint
                )
            }
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .cardSurface()
        .accessibilityElement(children: .combine)
    }
    
    // MARK: States
    
    private var loadingRow: some View {
        Section {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 160)
        }
        .listRowBackground(Color.clear)
    }
    
    private var emptyMonth: some View {
        VStack(spacing: Spacing.md) {
            IconTile(
                systemName: "calendar",
                foreground: Color.theme.accentText,
                background: Color.theme.accentTint,
                size: 56
            )
            
            Text(L10n.History.emptyMonth)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(Spacing.xxl)
    }
    
    private var failureRow: some View {
        Section {
            VStack(spacing: Spacing.md) {
                IconTile(
                    systemName: "exclamationmark.triangle.fill",
                    foreground: Color.theme.warning,
                    background: Color.theme.warningTint,
                    size: 56
                )
                
                Text(L10n.History.loadFailedTitle)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                
                Text(L10n.History.loadFailedMessage)
                    .font(Font.theme.rowSubtitle)
                    .foregroundStyle(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                
                Button(CommonText.tryAgain) {
                    Task { await viewModel.reload() }
                }
                .buttonStyle(.secondaryAction)
                .fixedSize()
                .padding(.top, Spacing.sm)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.xxl)
        }
        .listRowBackground(Color.clear)
    }
}
