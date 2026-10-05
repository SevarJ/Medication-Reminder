//
//  EditorStepViews.swift
//  DashboardImpl
//
//  Created by Sevar Jafarli on 06.10.26.
//

import AppFormatters
import DesignSystem
import Domain
import PhotosUI
import SwiftUI

/// What a step asks for. The adding flow shows these one at a time, and editing opens one from the summary.
struct EditorStepContent: View {
    let step: EditorStep
    @Bindable var viewModel: MedicationEditorViewModel
    
    var body: some View {
        switch step {
        case .details: DetailsStepView(viewModel: viewModel)
        case .schedule: ScheduleStepView(viewModel: viewModel)
        case .duration: DurationStepView(viewModel: viewModel)
        case .extras: ExtrasStepView(viewModel: viewModel)
        }
    }
}

// MARK: - Details

/// The big numbers the user types or taps: large enough to read, smaller than a screen title.
private let numberFont = Font.system(.title, design: .rounded, weight: .semibold).monospacedDigit()

private struct DetailsStepView: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    @State private var pickerItem: PhotosPickerItem?
    @FocusState private var isNameFocused: Bool
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            photoSection
            
            CardSection {
                TextField(L10n.Editor.namePlaceholder, text: $viewModel.name)
                    .font(Font.theme.sectionTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .padding(Spacing.lg)
                    .frame(minHeight: Size.primaryButton)
            }
            
            doseSection
        }
    }
    
    private var photoSection: some View {
        VStack(spacing: Spacing.md) {
            PhotosPicker(selection: $pickerItem, matching: .images) {
                if viewModel.photo != nil {
                    MedicationAvatar(photo: viewModel.photo, size: 104)
                }
                else {
                    IconTile(
                        systemName: "photo.badge.plus",
                        foreground: Color.theme.accentText,
                        background: Color.theme.accentTint,
                        size: 104
                    )
                }
            }
            .accessibilityLabel(viewModel.photo == nil ? L10n.Form.addPhoto : L10n.Form.changePhoto)
            
            HStack(spacing: Spacing.lg) {
                PhotosPicker(
                    viewModel.photo == nil ? L10n.Form.addPhoto : L10n.Form.changePhoto,
                    selection: $pickerItem,
                    matching: .images
                )
                .font(.system(.subheadline, weight: .semibold))
                .tint(Color.theme.accentText)
                
                if viewModel.photo != nil {
                    Button(L10n.Form.removePhoto, role: .destructive) {
                        viewModel.photo = nil
                    }
                    .font(.system(.subheadline, weight: .semibold))
                }
            }
            .frame(minHeight: Size.minTarget)
            
            Text(L10n.Form.photoHint)
                .font(Font.theme.caption)
                .foregroundStyle(Color.theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
        }
        .frame(maxWidth: .infinity)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let photo = MedicationPhoto.compressed(data) {
                    viewModel.photo = photo
                }
                
                pickerItem = nil
            }
        }
    }
    
    private var doseSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Editor.dosage)
            
            CardSection {
                HStack(spacing: Spacing.md) {
                    stepButton(systemName: "minus", label: L10n.Form.decreaseDose) {
                        viewModel.stepAmount(by: -1)
                    }
                    
                    TextField(L10n.Editor.amount, text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(numberFont)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(Color.theme.textPrimary)
                        .frame(maxWidth: .infinity)
                    
                    stepButton(systemName: "plus", label: L10n.Form.increaseDose) {
                        viewModel.stepAmount(by: 1)
                    }
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
    
    private func stepButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(.title3, weight: .bold))
                .foregroundStyle(Color.theme.accentText)
                .frame(width: Size.primaryButton, height: Size.primaryButton)
                .background(Color.theme.accentTint, in: Circle())
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

// MARK: - Schedule

private struct ScheduleStepView: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            repeatSection
            timesSection
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
    
    private var timesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Editor.reminders)
            
            CardSection {
                ForEach(viewModel.times) { time in
                    if time.id != viewModel.times.first?.id {
                        RowSeparator()
                    }
                    
                    timeRow(time)
                }
                
                if viewModel.canAddTime {
                    RowSeparator()
                    
                    Button {
                        withAnimation(.snappy) { viewModel.addTime() }
                    } label: {
                        Label(L10n.Editor.addTime, systemImage: "plus.circle.fill")
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
    
    private func timeRow(_ time: MedTime) -> some View {
        let isSelected = viewModel.selectedTimeId == time.id
        
        return VStack(spacing: 0) {
            HStack(spacing: Spacing.md) {
                Button {
                    withAnimation(.snappy) { viewModel.selectedTimeId = isSelected ? nil : time.id }
                } label: {
                    HStack {
                        Text(time.displayText)
                            .font(numberFont)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .foregroundStyle(isSelected ? Color.theme.accentText : Color.theme.textPrimary)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: Size.primaryButton)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                
                if viewModel.times.count > 1 {
                    Button {
                        withAnimation(.snappy) { viewModel.removeTime(id: time.id) }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(.title3))
                            .foregroundStyle(Color.theme.danger)
                            .frame(width: Size.minTarget, height: Size.minTarget)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.Form.removeTime)
                }
            }
            .padding(.horizontal, Spacing.lg)
            
            if isSelected {
                DatePicker(
                    "",
                    selection: Binding(
                        get: { time.date },
                        set: { viewModel.updateTime(id: time.id, to: $0) }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding(.bottom, Spacing.sm)
                .transition(.opacity)
            }
        }
    }
}

// MARK: - Duration

private struct DurationStepView: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    var body: some View {
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
        .animation(.snappy, value: viewModel.hasEndDate)
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
}

// MARK: - Stock and notes

private struct ExtrasStepView: View {
    @Bindable var viewModel: MedicationEditorViewModel
    
    var body: some View {
        VStack(spacing: Spacing.xl) {
            stockSection
            notesSection
        }
    }
    
    private var stockSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Form.stockTitle)
            
            CardSection {
                AdaptiveStack {
                    TextField(L10n.Editor.amount, text: $viewModel.stockText)
                        .keyboardType(.decimalPad)
                        .font(numberFont)
                        .minimumScaleFactor(0.5)
                        .foregroundStyle(Color.theme.textPrimary)
                    
                    Text(viewModel.unit.displayText)
                        .font(Font.theme.rowSubtitle)
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .padding(Spacing.lg)
                .frame(minHeight: Size.primaryButton)
            }
            
            Text(L10n.Form.stockHint)
                .font(Font.theme.caption)
                .foregroundStyle(Color.theme.textSecondary)
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.sm)
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: L10n.Form.notesTitle)
            
            CardSection {
                TextField(L10n.Form.notesPlaceholder, text: $viewModel.notes, axis: .vertical)
                    .lineLimit(3...8)
                    .font(Font.theme.rowTitle)
                    .foregroundStyle(Color.theme.textPrimary)
                    .padding(Spacing.lg)
                    .frame(minHeight: 96, alignment: .topLeading)
                    .onChange(of: viewModel.notes) { _, notes in
                        if notes.count > Medication.notesLimit {
                            viewModel.notes = String(notes.prefix(Medication.notesLimit))
                        }
                    }
            }
        }
    }
}
