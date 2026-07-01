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

    func execute(year: Int, month: Int) -> [Expense] {
        return repository.fetchExpenses(year: year, month: month)
    }
}
