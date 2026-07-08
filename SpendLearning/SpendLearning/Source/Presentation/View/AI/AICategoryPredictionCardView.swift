//
//  AICategoryPredictionCardView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI
import Charts

struct CategoryChartItem {
    let categoryName: String
    let actual: Int
    let predicted: Int
}

struct AICategoryPredictionCardView: View {

    let items: [CategoryChartItem]

    var body: some View {
        VStack(spacing: 0) {
            header
            chart
        }
        .background(Color(UIColor.DesignSystem.surface))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var header: some View {
        HStack {
            Text("카테고리별 실제 vs 예측")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 10) {
                legendItem(title: "실제", color: Color(UIColor.DesignSystem.primary))
                legendItem(title: "예측", color: Color(UIColor.DesignSystem.secondary))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(UIColor.DesignSystem.surface))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(UIColor.DesignSystem.accent))
    }

    private func legendItem(title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Color(UIColor.DesignSystem.primary))
        }
    }

    private var chart: some View {
        Text("차트")
    }

    private func formatted(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: amount)) ?? "\(amount)") + "원"
    }
}
