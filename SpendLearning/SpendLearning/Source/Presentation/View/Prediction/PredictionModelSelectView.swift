//
//  PredictionModelSelectView.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/10/26.
//

import SwiftUI

struct PredictionModelSelectView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var selectedId: String
    @State private var modelPendingDelete: PredictionModelMetadata?

    let models: [PredictionModelMetadata]
    var onConfirm: (PredictionModelMetadata) -> Void
    var onDelete: (PredictionModelMetadata) -> Void

    init(
        models: [PredictionModelMetadata],
        currentModelId: String,
        onConfirm: @escaping (PredictionModelMetadata) -> Void,
        onDelete: @escaping (PredictionModelMetadata) -> Void
    ) {
        self.models = models
        self.onConfirm = onConfirm
        self.onDelete = onDelete
        self._selectedId = State(initialValue: currentModelId)
    }

    var body: some View {
        VStack(spacing: 0) {
            if models.isEmpty {
                emptyView
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(models, id: \.id) { model in
                            modelRow(model)
                                .onTapGesture {
                                    selectedId = model.id
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        modelPendingDelete = model
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(20)
                }

                confirmButton
            }
        }
        .background(Color(UIColor.DesignSystem.background))
        .alert(
            "모델 삭제",
            isPresented: Binding(
                get: { modelPendingDelete != nil },
                set: { if !$0 { modelPendingDelete = nil } }
            )
        ) {
            Button("삭제", role: .destructive) {
                if let target = modelPendingDelete {
                    if selectedId == target.id {
                        let remaining = models
                            .filter { $0.id != target.id }
                            .sorted { $0.createdAt > $1.createdAt }
                        selectedId = remaining.first?.id ?? ""
                    }
                    onDelete(target)
                }
                modelPendingDelete = nil
            }
            Button("취소", role: .cancel) {
                modelPendingDelete = nil
            }
        } message: {
            Text("\(modelPendingDelete?.id ?? "") 모델을 삭제할까요?\n삭제한 모델은 복구할 수 없어요.")
        }
    }

    private var emptyView: some View {
        VStack(spacing: 8) {
            Text("생성된 모델이 없어요")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(Color(UIColor.DesignSystem.primary))

            Text("소비를 꾸준히 기록하고 모델을 생성해보세요.")
                .font(.system(size: 13))
                .foregroundStyle(Color(UIColor.DesignSystem.subtitle))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func modelRow(_ model: PredictionModelMetadata) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.id)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(UIColor.DesignSystem.primary))

                Text("데이터 \(model.dataCount)개")
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
        formatter.dateFormat = "yyyy.MM.dd HH:mm 생성"
        return formatter.string(from: date)
    }
}
