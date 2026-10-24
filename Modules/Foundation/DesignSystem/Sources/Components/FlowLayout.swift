//
//  FlowLayout.swift
//  DesignSystem
//
//  Created by Sevar Jafarli on 24.10.26.
//

import SwiftUI

public struct FlowLayout: Layout {
    private let spacing: CGFloat

    public init(spacing: CGFloat = Spacing.sm) {
        self.spacing = spacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews, width: proposal.width ?? .infinity)
        let width = rows.map(\.width).max() ?? 0
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))

        return CGSize(width: width, height: height)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY

        for row in arrange(subviews, width: bounds.width) {
            var x = bounds.minX

            for index in row.indices {
                let size = subviews[index].sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))

                subviews[index].place(
                    at: CGPoint(x: x, y: y + (row.height - size.height) / 2),
                    proposal: ProposedViewSize(width: min(size.width, bounds.width), height: size.height)
                )
                x += size.width + spacing
            }

            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(_ subviews: Subviews, width maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            let itemWidth = min(size.width, maxWidth)
            let nextWidth = current.indices.isEmpty ? itemWidth : current.width + spacing + itemWidth

            if nextWidth > maxWidth && !current.indices.isEmpty {
                rows.append(current)
                current = Row(indices: [index], width: itemWidth, height: size.height)
            }
            else {
                current.indices.append(index)
                current.width = nextWidth
                current.height = max(current.height, size.height)
            }
        }

        if !current.indices.isEmpty {
            rows.append(current)
        }

        return rows
    }
}
