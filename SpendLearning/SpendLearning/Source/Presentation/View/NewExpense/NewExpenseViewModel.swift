//
//  NewExpenseViewModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation
import Combine

@MainActor
final class NewExpenseViewModel {

    // MARK: - Output
    @Published private(set) var selectedCategory: Category?
    var initialAmount: Int { editingExpense?.amount ?? 0 }
    var initialMemo: String { editingExpense?.memo ?? "" }

    // MARK: - Private
    private let expenseUseCase: ExpenseUseCaseProtocol
    private let date: Date
    private var amount: Int = 0
    private var memo: String = ""
    private let editingExpense: Expense?

    // MARK: - Init
    init(
        expenseUseCase: ExpenseUseCaseProtocol,
        date: Date, editingExpense: Expense? = nil
    ) {
        self.expenseUseCase = expenseUseCase
        self.date = date
        self.editingExpense = editingExpense

        if let expense = editingExpense {
            self.amount = expense.amount
            self.memo = expense.memo ?? ""
        }
    }

    // MARK: - Input
    func didSelectCategory(_ category: Category) {
        selectedCategory = category
    }

    func didInputAmount(_ amount: Int) {
        self.amount = amount
    }

    func didInputMemo(_ memo: String) {
        self.memo = memo
    }

    func didSaveExpense() async {
        guard let category = selectedCategory else { return }
        if let editing = editingExpense {
            await expenseUseCase.delete(editing)
        }
        let expense = Expense(
            date: date,
            category: category,
            memo: memo.isEmpty ? nil : memo,
            amount: amount
        )
        await expenseUseCase.add(expense)
    }
}
