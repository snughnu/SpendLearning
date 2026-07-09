//
//  AIView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI

struct AIView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("소비 예측")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(UIColor.DesignSystem.primary))
                    .padding(.top, 16)

                AIStatusCardView(
                    modelId: "CAT13A",
                    dataCount: 1204,
                    accuracy: 82,
                    onExtract: { print("모델 생성하기 탭") },
                    onSwitch: { print("모델 교체하기 탭") }
                )

                AIInsightCardView(items: [
                    AIInsightItemData(type: .abnormal, description: "이번 주 카페 지출이 평소보다 2.1배 많아요"),
                    AIInsightItemData(type: .forecast, description: "매주 월요일 교통비가 나가는 패턴이에요"),
                    AIInsightItemData(type: .unrecorded, description: "지난주 이맘때 교통비가 있었는데 이번 주엔 없네요"),
                ])

                AIPredictionCardView(
                    data: [
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
                    ],
                    today: 14,
                    lastDay: 31
                )

                AICategoryPredictionCardView(data: [
                    CategoryPredictionDataPoint(categoryName: "식비",     actual: 320000, predicted: 280000),
                    CategoryPredictionDataPoint(categoryName: "교통",     actual: 54000,  predicted: 60000),
                    CategoryPredictionDataPoint(categoryName: "카페",     actual: 87000,  predicted: 45000),
                    CategoryPredictionDataPoint(categoryName: "쇼핑",     actual: 152000, predicted: 200000),
                    CategoryPredictionDataPoint(categoryName: "구독",     actual: 29000,  predicted: 29000),
                    CategoryPredictionDataPoint(categoryName: "의료",     actual: 45000,  predicted: 30000),
                    CategoryPredictionDataPoint(categoryName: "운동",     actual: 62000,  predicted: 70000),
                    CategoryPredictionDataPoint(categoryName: "도서",     actual: 18000,  predicted: 25000),
                    CategoryPredictionDataPoint(categoryName: "영화",     actual: 24000,  predicted: 20000),
                    CategoryPredictionDataPoint(categoryName: "여행",     actual: 0,      predicted: 150000),
                    CategoryPredictionDataPoint(categoryName: "숙박",     actual: 0,      predicted: 80000),
                    CategoryPredictionDataPoint(categoryName: "미용",     actual: 35000,  predicted: 40000),
                    CategoryPredictionDataPoint(categoryName: "반려동물", actual: 55000,  predicted: 50000),
                    CategoryPredictionDataPoint(categoryName: "세금",     actual: 120000, predicted: 120000),
                    CategoryPredictionDataPoint(categoryName: "보험",     actual: 80000,  predicted: 80000),
                    CategoryPredictionDataPoint(categoryName: "통신",     actual: 55000,  predicted: 55000),
                    CategoryPredictionDataPoint(categoryName: "게임",     actual: 12000,  predicted: 15000),
                    CategoryPredictionDataPoint(categoryName: "음악",     actual: 9000,   predicted: 9000),
                    CategoryPredictionDataPoint(categoryName: "편의점",   actual: 43000,  predicted: 35000),
                    CategoryPredictionDataPoint(categoryName: "기타",     actual: 27000,  predicted: 30000),
                ].sorted { $0.predicted > $1.predicted })
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.DesignSystem.background))
        .scrollIndicators(.hidden)
    }
}
