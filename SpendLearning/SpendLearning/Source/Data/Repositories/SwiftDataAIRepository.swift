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
        let descriptor = FetchDescriptor<AIModelModel>()
        let models = (try? modelContext.fetch(descriptor)) ?? []
        return models
            .sorted {
                if $0.isSelected != $1.isSelected { return $0.isSelected }
                return $0.createdAt > $1.createdAt
            }
            .map { toMetadata($0) }
    }

    func fetchCurrentModel() async -> AIModelMetadata? {
        let descriptor = FetchDescriptor<AIModelModel>()
        let models = (try? modelContext.fetch(descriptor)) ?? []
        return models.first { $0.isSelected }.map { toMetadata($0) }
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

        // 기존 모델 선택 해제
        let descriptor = FetchDescriptor<AIModelModel>()
        let existing = (try? modelContext.fetch(descriptor)) ?? []
        existing.forEach { $0.isSelected = false }

        let id = "SP\(UUID().uuidString.prefix(6).lowercased())"
        let model = AIModelModel(
            id: id,
            dataCount: expenses.count,
            accuracy: nil,
            createdAt: now,
            isSelected: true
        )
        modelContext.insert(model)
        try? modelContext.save()

        return .success(toMetadata(model))
    }

    func selectModel(id: String) async {
        let descriptor = FetchDescriptor<AIModelModel>()
        let models = (try? modelContext.fetch(descriptor)) ?? []
        models.forEach { $0.isSelected = ($0.id == id) }
        try? modelContext.save()
    }

    func deleteModel(id: String) async {
        let descriptor = FetchDescriptor<AIModelModel>()
        let models = (try? modelContext.fetch(descriptor)) ?? []
        guard let target = models.first(where: { $0.id == id }) else { return }

        let wasSelected = target.isSelected
        modelContext.delete(target)

        if wasSelected {
            let remaining = models
                .filter { $0.id != id }
                .sorted { $0.createdAt > $1.createdAt }
            remaining.first?.isSelected = true
        }

        try? modelContext.save()
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
