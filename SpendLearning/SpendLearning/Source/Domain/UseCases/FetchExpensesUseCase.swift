//
//  FetchExpensesUseCase.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Foundation

final class FetchExpensesUseCase {

    private let repository: ExpenseRepositoryProtocol

    init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    func execute(year: Int, month: Int) async -> [Expense] {
        return await repository.fetchExpenses(year: year, month: month)
    }
}
