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

    func fetchCurrentModel() async -> PredictionModelMetadata? {
        await repository.fetchCurrentModel()
    }

    func recalculate() async -> PredictionModelMetadata {
        let expenses = await expenseRepository.fetchAllExpenses()
        return await repository.recalculate(expenses: expenses)
    }
}
