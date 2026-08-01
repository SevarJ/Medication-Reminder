//
//  DesignSystemCatalog.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

struct DesignSystemCatalog: View {
    private let swatches: [(String, Color)] = [
        ("background", Color.theme.background),
        ("surface", Color.theme.surface),
        ("accent", Color.theme.accent),
        ("accentTint", Color.theme.accentTint),
        ("textPrimary", Color.theme.textPrimary),
        ("textSecondary", Color.theme.textSecondary),
        ("danger", Color.theme.danger),
        ("separator", Color.theme.separator),
        ("morning", Color.theme.morning),
        ("evening", Color.theme.evening)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                colors
                typography
                components
            }
            .padding(.vertical, Spacing.xl)
        }
        .background(Color.theme.background)
    }

    private var colors: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Colors")
            CardSection {
                ForEach(Array(swatches.enumerated()), id: \.offset) { index, swatch in
                    HStack(spacing: Spacing.md) {
                        RoundedRectangle(cornerRadius: CornerRadius.tile)
                            .fill(swatch.1)
                            .frame(width: 36, height: 36)
                            .overlay {
                                RoundedRectangle(cornerRadius: CornerRadius.tile)
                                    .stroke(Color.theme.separator, lineWidth: 0.5)
                            }
                        Text(swatch.0)
                            .font(Font.theme.rowSubtitle)
                            .foregroundStyle(Color.theme.textPrimary)
                        Spacer()
                    }
                    .padding(Spacing.md)

                    if index < swatches.count - 1 {
                        RowSeparator(leadingInset: 60)
                    }
                }
            }
        }
    }

    private var typography: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Typography")
            CardSection {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Medications")
                        .font(Font.theme.screenTitle)
                    Text("Vitamin D")
                        .font(Font.theme.rowTitle)
                    Text("10 drops")
                        .font(Font.theme.rowSubtitle)
                    Text("Next dose in 40 minutes")
                        .font(Font.theme.caption)
                        .foregroundStyle(Color.theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.md)
            }
        }
    }

    private var components: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Components")
            CardSection {
                HStack(spacing: Spacing.md) {
                    IconTile(
                        systemName: "pill",
                        foreground: Color.theme.accent,
                        background: Color.theme.accentTint
                    )
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Aspirin")
                            .font(Font.theme.rowTitle)
                            .foregroundStyle(Color.theme.textPrimary)
                        Text("500 mg")
                            .font(Font.theme.rowSubtitle)
                            .foregroundStyle(Color.theme.textSecondary)
                    }
                    Spacer()
                }
                .padding(Spacing.md)

                RowSeparator(leadingInset: 60)

                HStack(spacing: Spacing.sm) {
                    Badge(title: "08:00")
                    Badge(title: "20:00")
                    Spacer()
                }
                .padding(Spacing.md)

                RowSeparator()

                HStack(spacing: Spacing.lg) {
                    Label("08:00", systemImage: "sun.max")
                        .font(Font.theme.rowSubtitle)
                        .foregroundStyle(Color.theme.morning)
                    Label("20:00", systemImage: "moon")
                        .font(Font.theme.rowSubtitle)
                        .foregroundStyle(Color.theme.evening)
                    Spacer()
                }
                .padding(Spacing.md)

                RowSeparator()

                DestructiveRow(title: "Delete medication") {}
            }
        }
    }
}

#Preview("Light") {
    DesignSystemCatalog()
}

#Preview("Dark") {
    DesignSystemCatalog()
        .preferredColorScheme(.dark)
}
