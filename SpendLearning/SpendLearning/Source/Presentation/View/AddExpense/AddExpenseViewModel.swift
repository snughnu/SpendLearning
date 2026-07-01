//
//  AddExpenseViewModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation
import Combine

@MainActor
final class AddExpenseViewModel {

    // MARK: - Output
    @Published private(set) var selectedCategory: Category?
    @Published private(set) var isSaveEnabled: Bool = false

    // MARK: - Private
    private let expenseUseCase: ExpenseUseCaseProtocol
    private let date: Date
    private var amount: Int = 0
    private var memo: String = ""

    // MARK: - Init
    init(expenseUseCase: ExpenseUseCaseProtocol, date: Date) {
        self.expenseUseCase = expenseUseCase
        self.date = date
    }

    // MARK: - Input
    func didInputAmount(_ amount: Int) {
        self.amount = amount
        updateSaveEnabled()
    }

    func didSelectCategory(_ category: Category) {
        selectedCategory = category
        updateSaveEnabled()
    }

    func didInputMemo(_ memo: String) {
        self.memo = memo
    }

    func didSaveExpense() async {
        guard isSaveEnabled, let category = selectedCategory else { return }
        let expense = Expense(
            date: date,
            category: category,
            memo: memo.isEmpty ? nil : memo,
            amount: amount
        )
        await expenseUseCase.add(expense)
    }
}

// MARK: - Helper
private extension AddExpenseViewModel {

    func updateSaveEnabled() {
        isSaveEnabled = amount > 0 && selectedCategory != nil
    }
}
