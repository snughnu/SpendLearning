//
//  PredictionView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI

struct PredictionView: View {

    @State var viewModel: PredictionViewModel
    @State private var isShowingSuccessToast = false

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

                    PredictionStatusCardView(
                        currentModel: viewModel.currentModel,
                        accuracy: viewModel.accuracy,
                        isRecalculating: viewModel.isRecalculating,
                        onRecalculate: {
                            await viewModel.recalculate()
                            if viewModel.recalculateError == nil {
                                isShowingSuccessToast = true
                            }
                        },
                        recalculateError: viewModel.recalculateError
                    )
                }

                DailyPredictionCardView(
                    data: viewModel.predictionData,
                    today: viewModel.today,
                    lastDay: viewModel.lastDay,
                    hasPrediction: viewModel.hasPrediction
                )

                CategoryPredictionCardView(
                    data: viewModel.categoryData,
                    hasPrediction: viewModel.hasPrediction
                )
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
        }
        .background(Color(UIColor.DesignSystem.background))
        .scrollIndicators(.hidden)
        .onAppear {
            Task {
                await viewModel.onAppear()
            }
        }
        .toast(isShowing: $isShowingSuccessToast, message: "예측이 계산되었어요")
    }
}
