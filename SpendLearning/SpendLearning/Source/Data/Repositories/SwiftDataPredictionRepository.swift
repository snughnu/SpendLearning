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

    func recalculate(expenses: [Expense]) async -> Result<PredictionModelMetadata, PredictionModelCreationError> {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        // 저번 달 소비가 1건 이상 있어야 계산 가능
        let lastMonthExpenses = expenses.filter {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return !(y == currentYear && m == currentMonth)
        }
        guard !lastMonthExpenses.isEmpty else { return .failure(.insufficientData) }

        let dailyPredictions = await predictor.predictDaily(expenses: expenses, year: currentYear, month: currentMonth)
        let categoryPredictions = await predictor.predictCategory(expenses: expenses, year: currentYear, month: currentMonth)

        if let existing = fetchStoredModel() {
            existing.update(
                dataCount: expenses.count,
                createdAt: now,
                dailyPredictions: dailyPredictions,
                categoryPredictions: categoryPredictions
            )
            try? modelContext.save()
            return .success(toMetadata(existing))
        }

        let id = "SP\(UUID().uuidString.prefix(6).lowercased())"
        let model = PredictionModel(
            id: id,
            dataCount: expenses.count,
            createdAt: now,
            dailyPredictions: dailyPredictions,
            categoryPredictions: categoryPredictions
        )
        modelContext.insert(model)
        try? modelContext.save()

        return .success(toMetadata(model))
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
