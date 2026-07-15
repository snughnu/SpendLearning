//
//  PredictionUseCase.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

final class PredictionUseCase: PredictionUseCaseProtocol {

    private let repository: PredictionRepositoryProtocol
    private let expenseRepository: ExpenseRepositoryProtocol

    init(
        repository: PredictionRepositoryProtocol,
        expenseRepository: ExpenseRepositoryProtocol
    ) {
        self.repository = repository
        self.expenseRepository = expenseRepository
    }

    func fetchModels() async -> [PredictionModelMetadata] {
        await repository.fetchModels()
    }

    func fetchCurrentModel() async -> PredictionModelMetadata? {
        await repository.fetchCurrentModel()
    }

    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] {
        await repository.fetchDailyPredictions(year: year, month: month)
    }

    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] {
        await repository.fetchCategoryPredictions(year: year, month: month)
    }

    func createModel() async -> Result<PredictionModelMetadata, PredictionModelCreationError> {
        let expenses = await expenseRepository.fetchAllExpenses()
        return await repository.createModel(expenses: expenses)
    }

    func selectModel(id: String) async {
        await repository.selectModel(id: id)
    }

    func deleteModel(id: String) async {
        await repository.deleteModel(id: id)
    }
}
