//
//  AIStatusCardView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI

struct AIStatusCardView: View {

    let currentModel: AIModelMetadata?
    let models: [AIModelMetadata]

    @Binding var isShowingToast: Bool
    @State private var isShowingCreate = false
    @State private var isShowingSelect = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            modelInfo
            buttons
        }
        .background(Color(UIColor.DesignSystem.surface))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .alert("모델 생성", isPresented: $isShowingCreate) {
            Button("생성하기") {
                print("전체 데이터로 모델 생성")
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("데이터를 학습해 예측 모델을 생성할까요?")
        }
        .tint(Color(UIColor.DesignSystem.accent))
        .sheet(isPresented: $isShowingSelect) {
            AIModelSelectView(
                models: models,
                currentModelId: currentModel?.id ?? ""
            ) { selected in
                print("선택된 모델: \(selected.id)")
            }
        }
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
                        Text("\(model.id) 예측 모델 (\(Int(model.accuracy))%)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(UIColor.DesignSystem.primary))

                        Text("학습에 사용된 데이터: \(model.dataCount)개")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(UIColor.DesignSystem.subtitle))

                        ProgressView(value: model.accuracy / 100)
                            .tint(Color(UIColor.DesignSystem.accent))
                            .scaleEffect(x: 1, y: 2)
                            .padding(.top, 2)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    Text("예측 모델이 없어요")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(UIColor.DesignSystem.primary))

                    Text("소비를 꾸준히 기록할수록 모델이 더 정확해져요.\n기록이 쌓이면 아래 '모델 생성하기' 버튼을 눌러\n나만의 예측 모델을 만들어보세요!")
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
        HStack(spacing: 12) {
            Button {
                isShowingCreate = true
            } label: {
                Text("모델 생성하기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(UIColor.DesignSystem.primary))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                if models.isEmpty {
                    isShowingToast = true
                } else {
                    isShowingSelect = true
                }
            } label: {
                Text("모델 교체하기")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(UIColor.DesignSystem.accent).opacity(models.isEmpty ? 0.4 : 1.0))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
