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
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                AIStatusCardView(
                    modelId: "CAT13A",
                    dataCount: 1204,
                    accuracy: 82,
                    onExtract: { print("모델 생성하기 탭") },
                    onSwitch: { print("모델 교체하기 탭") }
                )
                .padding(.horizontal, 20)

                AIPredictionCardView(

                )
                .padding(.horizontal, 20)

                AICategoryPredictionCardView(items: [
                    CategoryChartItem(categoryName: "식비", actual: 320000, predicted: 280000),
                    CategoryChartItem(categoryName: "교통", actual: 54000, predicted: 60000),
                    CategoryChartItem(categoryName: "카페", actual: 87000, predicted: 45000),
                    CategoryChartItem(categoryName: "쇼핑", actual: 152000, predicted: 200000),
                    CategoryChartItem(categoryName: "구독", actual: 29000, predicted: 29000),
                ])
                .padding(.horizontal, 20)

                AIInsightCardView(items: [
                    AIInsightItemData(type: .abnormal, description: "이번 주 카페 지출이 평소보다 2.1배 많아요"),
                    AIInsightItemData(type: .forecast, description: "매주 월요일 교통비가 나가는 패턴이에요"),
                    AIInsightItemData(type: .unrecorded, description: "지난주 이맘때 교통비가 있었는데 이번 주엔 없네요"),
                ])
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(UIColor.DesignSystem.background))
        .scrollIndicators(.hidden)
    }
}
