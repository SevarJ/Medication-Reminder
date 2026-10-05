//
//  MedicationEditorView.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 12.09.26.
//

import AppFormatters
import AppLocalization
import DesignSystem
import Domain
import SwiftUI

struct MedicationEditorView: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    let onFinish: (Bool) -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.xl) {
                    detailsSection
                    repeatSection
                    durationSection
                    remindersSection
                    statusSection
                    
                    if onDelete != nil {
                        CardSection {
                            DestructiveRow(title: L10n.Editor.deleteMedication) {
                                onDelete?()
                            }
                        }
                    }
                }
                .padding(.vertical, Spacing.lg)
            }
            .background(Color.theme.background)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(CommonText.cancel, systemImage: "xmark") {
                        onFinish(false)
                    }
                    .labelStyle(.iconOnly)
                    .tint(Color.theme.accentText)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(CommonText.save) {
                        Task {
                            if await viewModel.save() {
                                onFinish(true)
                            }
                        }
                    }
                    .tint(Color.theme.accentText)
                    .disabled(viewModel.isSaving)
                }
            }
            .alert(
                L10n.Editor.invalidInputTitle,
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button(CommonText.ok, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Editor.details)
            
            CardSection {
                TextField(L10n.Editor.namePlaceholder, text: $viewModel.name)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .padding(Spacing.lg)
                
                RowSeparator()
                
                AdaptiveStack {
                    Text(L10n.Editor.dosage)
                        .font(Font.theme.rowTitle)
                        .foregroundStyle(Color.theme.textPrimary)
                    
                    Spacer(minLength: 0)
                    
                    TextField(L10n.Editor.amount, text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(Font.theme.rowSubtitle)
                        .foregroundStyle(Color.theme.textSecondary)
                        .frame(maxWidth: 80)
                }
                .padding(Spacing.lg)
                
                RowSeparator()
                
                Picker(L10n.Editor.unit, selection: $viewModel.unit) {
                    ForEach(DosageUnit.allCases, id: \.self) { unit in
                        Text(unit.displayText).tag(unit)
                    }
                }
                .pickerStyle(.segmented)
                .padding(Spacing.lg)
            }
        }
    }
    
    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Editor.repeatSection)
            
            CardSection {
                Picker(L10n.Editor.repeatSection, selection: $viewModel.repeatMode) {
                    ForEach(RepeatMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(Spacing.lg)
                
                if viewModel.repeatMode == .specificDays {
                    RowSeparator()
                    
                    HStack(spacing: 0) {
                        ForEach(Weekday.allCases, id: \.self) { weekday in
                            weekdayButton(weekday)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, Spacing.md)
                }
            }
        }
    }
    
    private func weekdayButton(_ weekday: Weekday) -> some View {
        let isSelected = viewModel.weekdays.contains(weekday)
        
        return Button {
            viewModel.toggleWeekday(weekday)
        } label: {
            Text(weekday.shortSymbol)
                .font(Font.theme.rowSubtitle)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Color.theme.onHero : Color.theme.textPrimary)
                .frame(width: 40, height: 40)
                .background(
                    isSelected ? Color.theme.hero : Color.theme.fill,
                    in: Circle()
                )
                .frame(maxWidth: .infinity, minHeight: Size.minTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Editor.duration)
            
            CardSection {
                datePickerRow(title: L10n.Editor.starts, selection: $viewModel.startDate)
                
                RowSeparator()
                
                ToggleRow(title: L10n.Editor.endDate, isOn: $viewModel.hasEndDate)
                
                if viewModel.hasEndDate {
                    RowSeparator()
                    
                    datePickerRow(
                        title: L10n.Editor.ends,
                        selection: $viewModel.endDate,
                        in: viewModel.startDate...
                    )
                }
            }
        }
    }
    
    private func datePickerRow(
        title: String,
        selection: Binding<Date>,
        in range: PartialRangeFrom<Date>? = nil
    ) -> some View {
        AdaptiveStack {
            Text(title)
                .font(Font.theme.rowTitle)
                .foregroundStyle(Color.theme.textPrimary)
            
            Spacer(minLength: 0)
            
            Group {
                if let range {
                    DatePicker("", selection: selection, in: range, displayedComponents: .date)
                }
                else {
                    DatePicker("", selection: selection, displayedComponents: .date)
                }
            }
            .labelsHidden()
            .fixedSize()
        }
        .padding(Spacing.lg)
    }
    
    private var remindersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Editor.reminders)
            
            CardSection {
                ForEach(viewModel.times) { time in
                    if time.id != viewModel.times.first?.id {
                        RowSeparator()
                    }
                    
                    HStack(spacing: Spacing.md) {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { time.date },
                                set: { viewModel.updateTime(id: time.id, to: $0) }
                            ),
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        
                        Spacer()
                        
                        if viewModel.times.count > 1 {
                            Button {
                                viewModel.removeTime(id: time.id)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(.title3))
                                    .foregroundStyle(Color.theme.danger)
                                    .frame(width: Size.minTarget, height: Size.minTarget)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(Spacing.lg)
                }
                
                if viewModel.canAddTime {
                    RowSeparator()
                    
                    Button {
                        viewModel.addTime()
                    } label: {
                        HStack(spacing: Spacing.sm) {
                            Image(systemName: "plus.circle.fill")
                            Text(L10n.Editor.addTime)
                        }
                        .font(Font.theme.rowTitle)
                        .foregroundStyle(Color.theme.accentText)
                        .frame(maxWidth: .infinity, minHeight: Size.minTarget, alignment: .leading)
                        .padding(.horizontal, Spacing.lg)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Editor.status)
            
            CardSection {
                ToggleRow(title: L10n.Editor.remindersEnabled, isOn: $viewModel.isActive)
            }
        }
    }
}
