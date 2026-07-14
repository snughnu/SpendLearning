//
//  AIView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI

struct AIView: View {

    @State var viewModel: AIViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("소비 예측")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(UIColor.DesignSystem.primary))
                    .padding(.top, 16)

                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.DesignSystem.accent))
                        .offset(y: -5)

                    AIStatusCardView(
                        modelId: viewModel.currentModel?.id ?? "-",
                        dataCount: viewModel.currentModel?.dataCount ?? 0,
                        accuracy: viewModel.currentModel?.accuracy ?? 0
                    )
                }

                AIInsightCardView(items: [])

                AIPredictionCardView(
                    data: viewModel.predictionData,
                    today: viewModel.today,
                    lastDay: viewModel.lastDay
                )

                AICategoryPredictionCardView(data: viewModel.categoryData)
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.DesignSystem.background))
        .scrollIndicators(.hidden)
        .onAppear {
            viewModel.onAppear()
        }
    }
}
