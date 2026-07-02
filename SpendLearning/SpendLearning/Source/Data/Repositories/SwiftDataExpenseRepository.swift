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
        return (try? modelContext.fetch(descriptor))?.map { toExpense($0) } ?? []
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
