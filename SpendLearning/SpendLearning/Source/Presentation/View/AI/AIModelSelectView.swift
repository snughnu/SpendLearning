//
//  AIModelSelectView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/10/26.
//

import SwiftUI

struct AIModelSelectView: View {

    @Environment(\.dismiss) private var dismiss

    let models: [AIModelMetadata]
    var onConfirm: (AIModelMetadata) -> Void

    @State private var selectedId: String

    init(
        models: [AIModelMetadata],
        currentModelId: String,
        onConfirm: @escaping (AIModelMetadata) -> Void
    ) {
        self.models = models
        self.onConfirm = onConfirm
        self._selectedId = State(initialValue: currentModelId)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(models, id: \.id) { model in
                        modelRow(model)
                            .onTapGesture {
                                selectedId = model.id
                            }
                    }
                }
                .padding(20)
            }

            confirmButton
        }
        .background(Color(UIColor.DesignSystem.background))
    }

    private func modelRow(_ model: AIModelMetadata) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.id)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(UIColor.DesignSystem.primary))

                Text("정확도 \(Int(model.accuracy))% · 데이터 \(model.dataCount)개")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(UIColor.DesignSystem.subtitle))

                Text(formattedDate(model.createdAt))
                    .font(.system(size: 12))
                    .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
            }

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color(UIColor.DesignSystem.secondary), lineWidth: 1.5)
                    .frame(width: 22, height: 22)

                if selectedId == model.id {
                    Circle()
                        .fill(Color(UIColor.DesignSystem.accent))
                        .frame(width: 13, height: 13)
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.DesignSystem.surface))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var confirmButton: some View {
        Button {
            if let selected = models.first(where: { $0.id == selectedId }) {
                onConfirm(selected)
            }
            dismiss()
        } label: {
            Text("적용하기")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(UIColor.DesignSystem.accent))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(20)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd 생성"
        return formatter.string(from: date)
    }
}
