//
//  SwiftDataAIRepository.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation
import SwiftData

final class SwiftDataAIRepository: AIRepositoryProtocol {

    private let modelContext: ModelContext
    private let expenseRepository: ExpenseRepositoryProtocol
    private let strategy = StatisticsPredictionStrategy()

    init(
        modelContext: ModelContext,
        expenseRepository: ExpenseRepositoryProtocol
    ) {
        self.modelContext = modelContext
        self.expenseRepository = expenseRepository
    }

    func fetchModels() async -> [AIModelMetadata] {
        let descriptor = FetchDescriptor<AIModelModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let models = (try? modelContext.fetch(descriptor)) ?? []
        return models.map { toMetadata($0) }
    }

    func fetchCurrentModel() async -> AIModelMetadata? {
        let descriptor = FetchDescriptor<AIModelModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let model = try? modelContext.fetch(descriptor).first
        return model.map { toMetadata($0) }
    }

    func fetchInsights() async -> [AIInsightItem] {
        guard hasSavedModel() else { return [] }
        let expenses = await expenseRepository.fetchAllExpenses()
        return strategy.predictInsights(expenses: expenses)
    }

    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] {
        guard hasSavedModel() else { return [:] }
        let expenses = await expenseRepository.fetchAllExpenses()
        return strategy.predictDaily(expenses: expenses, year: year, month: month)
    }

    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] {
        guard hasSavedModel() else { return [:] }
        let expenses = await expenseRepository.fetchAllExpenses()
        return strategy.predictCategory(expenses: expenses, year: year, month: month)
    }

    func createModel(expenses: [Expense]) async -> Result<AIModelMetadata, AIModelCreationError> {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        // 저번 달 소비가 1건 이상 있어야 생성 가능
        let lastMonthExpenses = expenses.filter {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return !(y == currentYear && m == currentMonth)
        }
        guard !lastMonthExpenses.isEmpty else { return .failure(.insufficientData) }

        let id = "SP\(UUID().uuidString.prefix(6).lowercased())"
        let metadata = AIModelMetadata(
            id: id,
            dataCount: expenses.count,
            accuracy: nil,
            createdAt: now
        )

        let model = AIModelModel(
            id: metadata.id,
            dataCount: metadata.dataCount,
            accuracy: nil,
            createdAt: metadata.createdAt
        )
        modelContext.insert(model)
        try? modelContext.save()

        return .success(metadata)
    }

    // MARK: - Private

    private func toMetadata(_ model: AIModelModel) -> AIModelMetadata {
        AIModelMetadata(
            id: model.id,
            dataCount: model.dataCount,
            accuracy: model.accuracy,
            createdAt: model.createdAt
        )
    }

    private func hasSavedModel() -> Bool {
        let descriptor = FetchDescriptor<AIModelModel>()
        return !((try? modelContext.fetch(descriptor)) ?? []).isEmpty
    }
}
