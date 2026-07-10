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
    let predicted: Int?
}

struct AICategoryPredictionCardView: View {

    let data: [CategoryPredictionDataPoint]

    @State private var isExpanded = false

    private var hasPrediction: Bool {
        data.compactMap { $0.predicted }.isEmpty == false
    }

    private var displayData: [CategoryPredictionDataPoint] {
        isExpanded ? data : Array(data.prefix(5))
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if !hasPrediction {
                noPredictionBanner
            }
            if data.isEmpty {
                emptyView
            } else {
                chart
                expandButton
            }
        }
        .background(Color(UIColor.DesignSystem.surface))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .animation(.easeInOut, value: isExpanded)
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

    private var noPredictionBanner: some View {
        Text("아직 예측 모델이 없어요")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(UIColor.DesignSystem.secondary).opacity(0.4))
    }

    private var emptyView: some View {
        Text("아직 데이터가 없어요")
            .font(.system(size: 14))
            .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
    }

    private var expandButton: some View {
        Button {
            isExpanded.toggle()
        } label: {
            Text(isExpanded ? "접기" : "전체보기 (\(data.count)개)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(UIColor.DesignSystem.primary))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
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
        let maxActual = displayData.map { $0.actual }.max() ?? 0
        let maxPredicted = displayData.compactMap { $0.predicted }.max() ?? 0
        let maxValue = max(maxActual, maxPredicted)

        return Chart {
            ForEach(displayData, id: \.categoryName) { item in
                BarMark(
                    x: .value("금액", max(item.actual, 1000)),
                    y: .value("카테고리", item.categoryName),
                    height: .fixed(11)
                )
                .foregroundStyle(Color(UIColor.DesignSystem.accent))
                .position(by: .value("타입", "실제"))
                .annotation(position: .trailing, alignment: .leading, spacing: 6) {
                    Text(formatted(item.actual))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(UIColor.DesignSystem.accent))
                }
            }

            ForEach(displayData, id: \.categoryName) { item in
                if let predicted = item.predicted {
                    BarMark(
                        x: .value("금액", max(predicted, 1000)),
                        y: .value("카테고리", item.categoryName),
                        height: .fixed(11)
                    )
                    .foregroundStyle(Color(UIColor.DesignSystem.chartPredicted))
                    .position(by: .value("타입", "예측"))
                    .annotation(position: .trailing, alignment: .leading, spacing: 6) {
                        Text(formatted(predicted))
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color(UIColor.DesignSystem.chartPredicted))
                    }
                }
            }
        }
        .chartXScale(domain: 0...Int(Double(maxValue) * 1.5))
        .chartXAxis {
            AxisMarks(position: .top) { value in
                AxisValueLabel {
                    if let amount = value.as(Int.self) {
                        Text(yAxisLabel(amount))
                            .font(.system(size: 10))
                            .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
                    }
                }
                AxisGridLine()
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let category = value.as(String.self) {
                        Text(category)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color(UIColor.DesignSystem.primary))
                            .lineLimit(1)
                    }
                }
            }
        }
        .frame(height: CGFloat(displayData.count) * 50)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
    }

    private func formatted(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return (formatter.string(from: NSNumber(value: amount)) ?? "\(amount)") + "원"
    }

    private func yAxisLabel(_ amount: Int) -> String {
        if amount >= 10000 {
            return "\(amount / 10000)만"
        } else {
            return formatted(amount)
        }
    }
}
