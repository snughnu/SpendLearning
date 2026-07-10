//
//  AIPredictionCardView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI
import Charts

struct PredictionDataPoint {
    let day: Int
    let actual: Int?
    let predicted: Int?
}

private struct CumulativeDataPoint {
    let day: Int
    let actual: Int?
    let predicted: Int?
}

struct AIPredictionCardView: View {

    let data: [PredictionDataPoint]
    let today: Int
    let lastDay: Int

    private var hasPrediction: Bool {
        data.compactMap { $0.predicted }.isEmpty == false
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            if !hasPrediction {
                noPredictionBanner
            }
            if data.compactMap({ $0.actual }).isEmpty {
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
            Text("이번 달 실제 vs 예측 (누적)")
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
        var cumulativeActual = 0
        var cumulativePredicted = 0
        let cumulativeData: [CumulativeDataPoint] = data.map { point in
            if let actual = point.actual {
                cumulativeActual += actual
            }
            if let predicted = point.predicted {
                cumulativePredicted += predicted
            }
            return CumulativeDataPoint(
                day: point.day,
                actual: point.actual != nil ? cumulativeActual : nil,
                predicted: point.predicted != nil ? cumulativePredicted : nil
            )
        }

        let actualValues = cumulativeData.compactMap { $0.actual }
        let predictedValues = cumulativeData.compactMap { $0.predicted }
        let maxValue = (actualValues + predictedValues).max() ?? 0
        let predictedTotal = cumulativeData.compactMap { $0.predicted }.last ?? 0

        return Chart {

            if hasPrediction {
                ForEach(cumulativeData, id: \.day) { point in
                    if let predicted = point.predicted {
                        LineMark(
                            x: .value("날짜", point.day),
                            y: .value("금액", predicted),
                            series: .value("타입", "예측")
                        )
                        .foregroundStyle(Color(UIColor.DesignSystem.chartPredicted))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 4]))
                    }
                }

                if let lastPoint = cumulativeData.last, let predicted = lastPoint.predicted {
                    PointMark(
                        x: .value("날짜", lastPoint.day),
                        y: .value("금액", predicted)
                    )
                    .foregroundStyle(Color(UIColor.DesignSystem.chartPredicted))
                    .annotation(position: .top) {
                        Text("예측 총 \(formatted(predictedTotal))")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(UIColor.DesignSystem.chartPredicted))
                    }
                }
            }

            ForEach(cumulativeData, id: \.day) { point in
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
                    let actualTotal = cumulativeData.filter { $0.day <= today }.compactMap { $0.actual }.last ?? 0
                    let predictedToday = cumulativeData.filter { $0.day <= today }.compactMap { $0.predicted }.last ?? 0

                    VStack(alignment: .leading, spacing: 2) {
                        Text("실제: \(formatted(actualTotal))")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(UIColor.DesignSystem.accent))
                        if hasPrediction {
                            Text("예측: \(formatted(predictedToday))")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color(UIColor.DesignSystem.chartPredicted))
                        }
                    }
                    .padding(6)
                    .background(Color(UIColor.DesignSystem.background))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }

            if let todayPoint = cumulativeData.first(where: { $0.day == today }),
               let actual = todayPoint.actual {
                PointMark(
                    x: .value("날짜", todayPoint.day),
                    y: .value("금액", actual)
                )
                .foregroundStyle(Color(UIColor.DesignSystem.accent))
            }
        }
        .chartXScale(domain: 1...40)
        .chartXAxis {
            let xAxisValues: [Int] = {
                var values = [1, lastDay]
                if today > 3 && today < lastDay - 3 {
                    values.insert(today, at: 1)
                }
                return values
            }()

            AxisMarks(values: xAxisValues) { value in
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
        .padding(.top, 50)
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
