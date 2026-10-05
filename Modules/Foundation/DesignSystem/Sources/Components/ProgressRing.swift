//
//  ProgressRing.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 24.09.26.
//

import SwiftUI

public struct ProgressRing: View {
    private let progress: Double
    private let lineWidth: CGFloat
    private let tint: Color
    private let track: Color

    public init(
        progress: Double,
        lineWidth: CGFloat = 8,
        tint: Color = Color.theme.accent,
        track: Color = Color.theme.fill
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.tint = tint
        self.track = track
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(track, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .padding(lineWidth / 2)
        .animation(.spring(duration: 0.6), value: progress)
    }
}
