//
//  AIUseCase.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

final class AIUseCase: AIUseCaseProtocol {

    private let repository: AIRepositoryProtocol
    private let expenseRepository: ExpenseRepositoryProtocol

    init(
        repository: AIRepositoryProtocol,
        expenseRepository: ExpenseRepositoryProtocol
    ) {
        self.repository = repository
        self.expenseRepository = expenseRepository
    }

    func fetchModels() async -> [AIModelMetadata] {
        await repository.fetchModels()
    }

    func fetchCurrentModel() async -> AIModelMetadata? {
        await repository.fetchCurrentModel()
    }

    func fetchInsights() async -> [AIInsightItem] {
        await repository.fetchInsights()
    }

    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] {
        await repository.fetchDailyPredictions(year: year, month: month)
    }

    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] {
        await repository.fetchCategoryPredictions(year: year, month: month)
    }

    func createModel() async -> Result<AIModelMetadata, AIModelCreationError> {
        let expenses = await expenseRepository.fetchAllExpenses()
        return await repository.createModel(expenses: expenses)
    }
}
