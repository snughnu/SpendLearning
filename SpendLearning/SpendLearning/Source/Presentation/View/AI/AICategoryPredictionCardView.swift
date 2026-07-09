//
//  AICategoryPredictionCardView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI
import Charts

struct CategoryPredictionDataPoint {
    let categoryName: String
    let actual: Int
    let predicted: Int
}

struct AICategoryPredictionCardView: View {

    let data: [CategoryPredictionDataPoint]

    var body: some View {
        VStack(spacing: 0) {
            header
            if data.isEmpty {
                emptyView
            } else {
                chart
            }
        }
        .background(Color(UIColor.DesignSystem.surface))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var header: some View {
        HStack {
            Text("카테고리별 이번 달 실제 vs 예측")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 10) {
                legendItem(title: "실제", color: Color(UIColor.DesignSystem.accent))
                legendItem(title: "예측", color: Color(UIColor.DesignSystem.chartPredicted))
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

    private var emptyView: some View {
        Text("아직 데이터가 없어요")
            .font(.system(size: 14))
            .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
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
