//
//  PredictionStatusCardView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI

struct PredictionStatusCardView: View {

    @State private var isShowingConfirm = false

    let currentModel: PredictionModelMetadata?
    let accuracy: Float?
    let isRecalculating: Bool
    let onRecalculate: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            modelInfo
            buttons
        }
        .background(Color(UIColor.DesignSystem.surface))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .alert("예측 다시 계산", isPresented: $isShowingConfirm) {
            Button("계산하기") {
                Task { await onRecalculate() }
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("지난달까지의 소비로 예측을 계산할까요?")
        }
        .tint(Color(UIColor.DesignSystem.accent))
    }

    private var modelInfo: some View {
        Group {
            if let model = currentModel {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "cpu")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 64, height: 64)
                        .foregroundStyle(Color(UIColor.DesignSystem.primary))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("예측 정확도" + (accuracy.map { " \(Int($0))%" } ?? ""))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(UIColor.DesignSystem.primary))

                        Text("계산에 사용된 데이터: \(model.dataCount)개")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(UIColor.DesignSystem.subtitle))

                        Text("지난달들의 기록이 쌓일수록 정확해져요")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(UIColor.DesignSystem.subtitle).opacity(0.8))

                        if let accuracy {
                            ProgressView(value: accuracy / 100)
                                .tint(Color(UIColor.DesignSystem.accent))
                                .scaleEffect(x: 1, y: 2)
                                .padding(.top, 2)
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("예측이 없어요")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(UIColor.DesignSystem.primary))

                    Text("소비를 꾸준히 기록할수록 예측이 더 정확해져요.\n기록이 쌓이면 아래 '계산하기' 버튼을 눌러\n나만의 예측을 만들어보세요!")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }

    private var buttons: some View {
        Button {
            isShowingConfirm = true
        } label: {
            Group {
                if isRecalculating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("계산하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(UIColor.DesignSystem.accent))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isRecalculating)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
