//
//  MockExpenseRepository.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Foundation

final class MockExpenseRepository: ExpenseRepositoryProtocol {

    private var expenses: [Expense] = {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        var components = DateComponents()
        components.year = year
        components.month = month

        func date(_ day: Int) -> Date? {
            components.day = day
            return calendar.date(from: components)
        }

        return [
            Expense(date: date(1), category: .food, memo: "김밥천국", amount: 8500),
            Expense(date: date(3), category: .cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(8), category: .transport, memo: "택시", amount: 12000),
            Expense(date: date(10), category: .shopping, memo: "다이소", amount: 15000),
            Expense(date: date(10), category: .food, memo: "한식당", amount: 12000),
            Expense(date: date(10), category: .medical, memo: "약국", amount: 8500),
            Expense(date: date(13), category: .cafe, memo: "투썸플레이스", amount: 6200),
            Expense(date: date(15), category: .food, memo: "점심", amount: 9000),
            Expense(date: date(15), category: .cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(15), category: .transport, memo: "택시", amount: 12000),
            Expense(date: date(18), category: .shopping, memo: "올리브영", amount: 9800),
            Expense(date: date(20), category: .food, memo: "저녁", amount: 67000),
            Expense(date: date(22), category: .cafe, memo: "카페", amount: 15000),
            Expense(date: date(25), category: .shopping, memo: "쿠팡", amount: 120000),
            Expense(date: date(28), category: .transport, memo: "지하철", amount: 4500),
            Expense(date: date(30), category: .food, memo: "외식", amount: 32000),
        ]
    }()

    func fetchExpenses(year: Int, month: Int) async -> [Expense] {
        let calendar = Calendar.current
        return expenses.filter {
            guard let date = $0.date else { return false }
            let y = calendar.component(.year, from: date)
            let m = calendar.component(.month, from: date)
            return y == year && m == month
        }
    }

    func deleteExpense(_ expense: Expense) async {
        expenses.removeAll { $0.id == expense.id }
    }

    func addExpense(_ expense: Expense) async {
        expenses.append(expense)
    }
}
