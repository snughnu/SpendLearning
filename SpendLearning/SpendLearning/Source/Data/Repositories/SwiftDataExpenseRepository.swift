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

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchExpenses(year: Int, month: Int) async -> [Expense] {
        let calendar = Calendar.current
        let descriptor = FetchDescriptor<ExpenseModel>()
        let models = (try? modelContext.fetch(descriptor)) ?? []
        return models
            .filter {
                calendar.component(.year, from: $0.date) == year
                && calendar.component(.month, from: $0.date) == month
            }
            .map { toExpense($0) }
    }

    func addExpense(_ expense: Expense) async {
        let model = toModel(expense)
        modelContext.insert(model)
        try? modelContext.save()
    }

    func deleteExpense(_ expense: Expense) async {
        let descriptor = FetchDescriptor<ExpenseModel>()
        let models = (try? modelContext.fetch(descriptor)) ?? []
        if let model = models.first(where: { $0.id == expense.id }) {
            modelContext.delete(model)
            try? modelContext.save()
        }
    }
}

// MARK: - Mapping
private extension SwiftDataExpenseRepository {

    func toExpense(_ model: ExpenseModel) -> Expense {
        let category = Category(rawValue: model.categoryRawValue) ?? .etc
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
            categoryRawValue: expense.category.rawValue,
            memo: expense.memo,
            amount: expense.amount
        )
    }
}
