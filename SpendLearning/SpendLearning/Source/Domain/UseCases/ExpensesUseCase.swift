//
//  ExpensesUseCase.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Foundation

final class ExpenseUseCase {

    private let repository: ExpenseRepositoryProtocol

    init(repository: ExpenseRepositoryProtocol) {
        self.repository = repository
    }

    func fetch(year: Int, month: Int) async -> [Expense] {
        await repository.fetchExpenses(year: year, month: month)
    }

    func delete(_ expense: Expense) async {
        await repository.deleteExpense(expense)
    }
}
