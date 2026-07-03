//
//  SwiftDataExpenseRepository.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation
import SwiftData

final class SwiftDataExpenseRepository: ExpenseRepositoryProtocol {

    private let modelContext: ModelContext
    private let categoryRepository: CategoryRepositoryProtocol

    init(modelContext: ModelContext, categoryRepository: CategoryRepositoryProtocol) {
        self.modelContext = modelContext
        self.categoryRepository = categoryRepository
    }

    func fetchExpenses(year: Int, month: Int) async -> [Expense] {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        let calendar = Calendar.current
        guard let startDate = calendar.date(from: components),
              let endDate = calendar.date(byAdding: .month, value: 1, to: startDate)
        else { return [] }

        let predicate = #Predicate<ExpenseModel> { model in
            model.date >= startDate && model.date < endDate
        }
        let descriptor = FetchDescriptor<ExpenseModel>(predicate: predicate)
        let models = (try? modelContext.fetch(descriptor)) ?? []
        let categories = (try? await categoryRepository.fetchCategories()) ?? []
        return models.map { toExpense($0, categories: categories) }
    }

    func addExpense(_ expense: Expense) async {
        let model = toModel(expense)
        modelContext.insert(model)
        try? modelContext.save()
    }

    func deleteExpense(_ expense: Expense) async {
        let targetID = expense.id
        let predicate = #Predicate<ExpenseModel> { $0.id == targetID }
        let descriptor = FetchDescriptor<ExpenseModel>(predicate: predicate)
        guard let model = try? modelContext.fetch(descriptor).first else { return }
        modelContext.delete(model)
        try? modelContext.save()
    }
}

// MARK: - Mapping
private extension SwiftDataExpenseRepository {

    func toExpense(_ model: ExpenseModel, categories: [Category]) -> Expense {
        let fallback = Category(name: "기타", emoji: "📦", isDeletable: false)
        let category = categories.first { $0.id == model.categoryID } ?? fallback
        return Expense(
            id: model.id,
            date: model.date,
            category: category,
            memo: model.memo,
            amount: model.amount
        )
    }

    func toModel(_ expense: Expense) -> ExpenseModel {
        ExpenseModel(
            id: expense.id,
            date: expense.date,
            categoryID: expense.category.id,
            memo: expense.memo,
            amount: expense.amount
        )
    }
}
