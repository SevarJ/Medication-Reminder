//
//  RowSeparator.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 01.08.26.
//

import SwiftUI

public struct RowSeparator: View {
    private let leadingInset: CGFloat

    public init(leadingInset: CGFloat = Spacing.lg) {
        self.leadingInset = leadingInset
    }

    public var body: some View {
        Rectangle()
            .fill(Color.theme.separator)
            .frame(height: 0.5)
            .padding(.leading, leadingInset)
    }
}
