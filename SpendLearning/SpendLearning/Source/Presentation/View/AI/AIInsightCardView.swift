//
//  AIInsightCardView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI

struct AIInsightCardView: View {

    let items: [AIInsightItem]

    var body: some View {
        VStack(spacing: 0) {
            header

            if items.isEmpty {
                emptyView
            } else {
                bodyView
            }
        }
        .background(Color(UIColor.DesignSystem.surface))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var header: some View {
        HStack {
            Text("인사이트")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color(UIColor.DesignSystem.accent))
    }

    private var emptyView: some View {
        Text("아직 패턴을 분석 중이에요")
            .font(.system(size: 14))
            .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
    }

    private var bodyView: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                rowView(item: item)

                if index < items.count - 1 {
                    Divider()
                        .background(Color(UIColor.DesignSystem.separator))
                        .padding(.horizontal, 12)
                }
            }
        }
    }

    private func rowView(item: AIInsightItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.type.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(UIColor.DesignSystem.primary))

            Text(item.description)
                .font(.system(size: 12))
                .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}
