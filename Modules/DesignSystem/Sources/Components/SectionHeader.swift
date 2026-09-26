//
//  SectionHeader.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct SectionHeader: View {
    private let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(Font.theme.rowSubtitle)
            .foregroundStyle(Color.theme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.lg)
            .padding(.bottom, Spacing.sm)
    }
}
