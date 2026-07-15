//
//  SwiftDataPredictionRepository.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation
import SwiftData

final class SwiftDataPredictionRepository: PredictionRepositoryProtocol {

    private let modelContext: ModelContext
    private let expenseRepository: ExpenseRepositoryProtocol
    private let predictor = StatisticsPredictor()

    init(
        modelContext: ModelContext,
        expenseRepository: ExpenseRepositoryProtocol
    ) {
        self.modelContext = modelContext
        self.expenseRepository = expenseRepository
    }

    func fetchCurrentModel() async -> PredictionModelMetadata? {
        fetchStoredModel().map { toMetadata($0) }
    }

    func deleteModel() async {
        guard let existing = fetchStoredModel() else { return }
        modelContext.delete(existing)
        try? modelContext.save()
    }

    func recalculate(expenses: [Expense]) async -> PredictionModelMetadata {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        // 예측 계산에는 이번 달을 제외한 과거 데이터만 사용되므로, 표시용 데이터 개수도 이에 맞춘다.
        let pastExpenseCount = expenses.filter {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return !(y == currentYear && m == currentMonth)
        }.count

        let dailyPredictions = await predictor.predictDaily(expenses: expenses, year: currentYear, month: currentMonth)
        let categoryPredictions = await predictor.predictCategory(expenses: expenses, year: currentYear, month: currentMonth)

        if let existing = fetchStoredModel() {
            existing.update(
                dataCount: pastExpenseCount,
                createdAt: now,
                dailyPredictions: dailyPredictions,
                categoryPredictions: categoryPredictions
            )
            try? modelContext.save()
            return toMetadata(existing)
        }

        let id = "SP\(UUID().uuidString.prefix(6).lowercased())"
        let model = PredictionModel(
            id: id,
            dataCount: pastExpenseCount,
            createdAt: now,
            dailyPredictions: dailyPredictions,
            categoryPredictions: categoryPredictions
        )
        modelContext.insert(model)
        try? modelContext.save()

        return toMetadata(model)
    }

    // MARK: - Private

    private func fetchStoredModel() -> PredictionModel? {
        let descriptor = FetchDescriptor<PredictionModel>()
        return ((try? modelContext.fetch(descriptor)) ?? []).first
    }

    private func toMetadata(_ model: PredictionModel) -> PredictionModelMetadata {
        PredictionModelMetadata(
            id: model.id,
            dataCount: model.dataCount,
            createdAt: model.createdAt,
            dailyPredictions: model.dailyPredictions,
            categoryPredictions: model.categoryPredictions
        )
    }
}
