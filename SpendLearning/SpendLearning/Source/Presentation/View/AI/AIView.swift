//
//  AIView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI

struct AIView: View {

    @State var viewModel: AIViewModel
    @State private var isShowingToast = false
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

                    AIStatusCardView(
                        isShowingToast: $isShowingToast,
                        currentModel: viewModel.currentModel,
                        models: viewModel.models,
                        isCreatingModel: viewModel.isCreatingModel,
                        onCreateModel: {
                            await viewModel.createModel()
                            if viewModel.createModelError == nil {
                                isShowingSuccessToast = true
                            }
                        },
                        createModelError: viewModel.createModelError,
                        onSelectModel: { selected in
                            await viewModel.selectModel(id: selected.id)
                        },
                        onDeleteModel: { target in
                            await viewModel.deleteModel(id: target.id)
                        }
                    )
                }

                AIInsightCardView(items: viewModel.sortedInsights, hasPrediction: viewModel.hasPrediction)

                AIPredictionCardView(
                    data: viewModel.predictionData,
                    today: viewModel.today,
                    lastDay: viewModel.lastDay,
                    hasPrediction: viewModel.hasPrediction
                )

                AICategoryPredictionCardView(
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
        .toast(isShowing: $isShowingToast, message: "아직 생성된 예측 모델이 없어요")
        .toast(isShowing: $isShowingSuccessToast, message: "예측 모델이 생성되었어요")
    }
}
