//
//  AIPredictionCardView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI
import Charts

struct PredictionDataPoint {
    let day: Int        // 1~31
    let actual: Int?    // 아직 지나지 않은 날은 nil
    let predicted: Int
}

struct AIPredictionCardView: View {

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
            Text("이번 달 실제 vs 예측")
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

    private func legendItem(title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 12, height: 3)
            Text(title)
                .font(.system(size: 11))
                .foregroundStyle(Color(UIColor.DesignSystem.primary))
        }
    }

    private var chart: some View {
        let data: [PredictionDataPoint] = [
            PredictionDataPoint(day: 1,  actual: 12000,  predicted: 15000),
            PredictionDataPoint(day: 2,  actual: 28000,  predicted: 30000),
            PredictionDataPoint(day: 3,  actual: 45000,  predicted: 45000),
            PredictionDataPoint(day: 4,  actual: 67000,  predicted: 60000),
            PredictionDataPoint(day: 5,  actual: 82000,  predicted: 75000),
            PredictionDataPoint(day: 6,  actual: 95000,  predicted: 90000),
            PredictionDataPoint(day: 7,  actual: 110000, predicted: 105000),
            PredictionDataPoint(day: 8,  actual: 125000, predicted: 120000),
            PredictionDataPoint(day: 9,  actual: 138000, predicted: 135000),
            PredictionDataPoint(day: 10, actual: 152000, predicted: 150000),
            PredictionDataPoint(day: 11, actual: 170000, predicted: 165000),
            PredictionDataPoint(day: 12, actual: 185000, predicted: 180000),
            PredictionDataPoint(day: 13, actual: 198000, predicted: 195000),
            PredictionDataPoint(day: 14, actual: 215000, predicted: 210000),
            PredictionDataPoint(day: 15, actual: nil,    predicted: 225000),
            PredictionDataPoint(day: 16, actual: nil,    predicted: 240000),
            PredictionDataPoint(day: 17, actual: nil,    predicted: 255000),
            PredictionDataPoint(day: 18, actual: nil,    predicted: 270000),
            PredictionDataPoint(day: 19, actual: nil,    predicted: 285000),
            PredictionDataPoint(day: 20, actual: nil,    predicted: 300000),
            PredictionDataPoint(day: 21, actual: nil,    predicted: 315000),
            PredictionDataPoint(day: 22, actual: nil,    predicted: 330000),
            PredictionDataPoint(day: 23, actual: nil,    predicted: 345000),
            PredictionDataPoint(day: 24, actual: nil,    predicted: 360000),
            PredictionDataPoint(day: 25, actual: nil,    predicted: 375000),
            PredictionDataPoint(day: 26, actual: nil,    predicted: 390000),
            PredictionDataPoint(day: 27, actual: nil,    predicted: 405000),
            PredictionDataPoint(day: 28, actual: nil,    predicted: 420000),
            PredictionDataPoint(day: 29, actual: nil,    predicted: 435000),
            PredictionDataPoint(day: 30, actual: nil,    predicted: 450000),
            PredictionDataPoint(day: 31, actual: nil,    predicted: 465000),
        ]

        let today = 1
        let lastDay = 31
        let maxValue = data.flatMap { [$0.actual ?? 0, $0.predicted] }.max() ?? 0

        return Chart {

            ForEach(data, id: \.day) { point in
                LineMark(
                    x: .value("날짜", point.day),
                    y: .value("금액", point.predicted),
                    series: .value("타입", "예측")
                )
                .foregroundStyle(Color(UIColor.DesignSystem.chartPredicted))
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 4]))
            }

            ForEach(data, id: \.day) { point in
                if let actual = point.actual {
                    LineMark(
                        x: .value("날짜", point.day),
                        y: .value("금액", actual),
                        series: .value("타입", "실제")
                    )
                    .foregroundStyle(Color(UIColor.DesignSystem.accent))
                }
            }

            RuleMark(x: .value("오늘", today))
                .foregroundStyle(Color(UIColor.DesignSystem.subtitle).opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                .annotation(position: .top) {
                    Text("오늘(\(today)일)")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
                }
        }
        .chartXScale(domain: 1...35)
        .chartXAxis {
            AxisMarks(values: [1, lastDay]) { value in
                AxisValueLabel {
                    if let day = value.as(Int.self) {
                        Text("\(day)일")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
                    }
                }
                AxisGridLine()
            }
        }
        .chartYScale(domain: 0...Int(Double(maxValue) * 1.1))
        .chartYAxis {
            AxisMarks(position: .leading) { value in
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
        .frame(height: 200)
        .padding(.top, 20)
        .padding(.bottom, 8)
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
