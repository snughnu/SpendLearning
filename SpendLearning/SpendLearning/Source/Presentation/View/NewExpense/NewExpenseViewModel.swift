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
    @Published private(set) var categories: [Category] = []
    @Published private(set) var fetchError: Error? = nil

    var initialAmount: Int { amount }
    var initialMemo: String { memo }
    var finalMemo: String { memo }

    // MARK: - Private
    private let expenseUseCase: ExpenseUseCaseProtocol
    private let categoryUseCase: CategoryUseCaseProtocol
    private let date: Date
    private var amount: Int = 0
    private var memo: String = ""
    private let editingExpense: Expense?

    // MARK: - Init
    init(
        expenseUseCase: ExpenseUseCaseProtocol,
        categoryUseCase: CategoryUseCaseProtocol,
        date: Date,
        editingExpense: Expense? = nil,
        prefillAmount: Int? = nil,
        prefillMemo: String? = nil,
        prefillCategory: Category? = nil
    ) {
        self.expenseUseCase = expenseUseCase
        self.categoryUseCase = categoryUseCase
        self.date = date
        self.editingExpense = editingExpense

        if let expense = editingExpense {
            self.amount = expense.amount
            self.memo = expense.memo ?? ""
            self.selectedCategory = expense.category
        } else {
            self.amount = prefillAmount ?? 0
            self.memo = prefillMemo ?? ""
            self.selectedCategory = prefillCategory
        }
    }

    // MARK: - Input
    func loadCategories() async {
        do {
            categories = try await categoryUseCase.fetchCategories()
            fetchError = nil
        } catch {
            fetchError = error
        }
    }

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
