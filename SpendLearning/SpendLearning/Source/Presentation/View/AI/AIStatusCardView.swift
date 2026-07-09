//
//  AIStatusCardView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/8/26.
//

import SwiftUI

struct AIStatusCardView: View {

    let modelId: String
    let dataCount: Int
    let accuracy: Float

    @State private var isShowingCreate = false
    @State private var isShowingSelect = false

    private let mockModels: [AIModelItem] = [
        AIModelItem(id: "CAT13A", dataCount: 1204, accuracy: 82, createdAt: Date()),
        AIModelItem(id: "CAT12B", dataCount: 980,  accuracy: 76, createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()),
        AIModelItem(id: "CAT11C", dataCount: 750,  accuracy: 71, createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "cpu")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(Color(UIColor.DesignSystem.primary))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(modelId) 예측 모델 (\(Int(accuracy))%)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Color(UIColor.DesignSystem.primary))

                    Text("학습에 사용된 데이터: \(dataCount)개")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(UIColor.DesignSystem.subtitle))

                    ProgressView(value: accuracy / 100)
                        .tint(Color(UIColor.DesignSystem.accent))
                        .scaleEffect(x: 1, y: 2)
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 20)

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
                    isShowingSelect = true
                } label: {
                    Text("모델 교체하기")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(UIColor.DesignSystem.accent))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
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
        .sheet(isPresented: $isShowingSelect) {
            AIModelSelectView(
                models: mockModels,
                currentModelId: modelId
            ) { selected in
                print("선택된 모델: \(selected.id)")
            }
        }
    }
}
