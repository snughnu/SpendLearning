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

        let food = Category(name: "식비", emoji: "🍚")
        let cafe = Category(name: "카페/간식", emoji: "☕️")
        let transport = Category(name: "교통", emoji: "🚌")
        let shopping = Category(name: "쇼핑", emoji: "🛍️")
        let medical = Category(name: "의료/건강", emoji: "💊")

        func date(monthOffset: Int, day: Int) -> Date {
            var components = DateComponents()
            let targetMonth = month + monthOffset
            let targetYear = year + (targetMonth - 1) / 12
            components.year = targetYear
            components.month = ((targetMonth - 1 + 12) % 12) + 1
            components.day = day
            return calendar.date(from: components)!
        }

        // MARK: - 이번 달
        let thisMonth: [Expense] = [
            Expense(date: date(monthOffset: 0, day: 1), category: food, memo: "김밥천국", amount: 8500),
            Expense(date: date(monthOffset: 0, day: 3), category: cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(monthOffset: 0, day: 8), category: transport, memo: "택시", amount: 12000),
            Expense(date: date(monthOffset: 0, day: 10), category: shopping, memo: "다이소", amount: 15000),
            Expense(date: date(monthOffset: 0, day: 10), category: food, memo: "한식당", amount: 12000),
            Expense(date: date(monthOffset: 0, day: 10), category: medical, memo: "약국", amount: 8500),
            Expense(date: date(monthOffset: 0, day: 13), category: cafe, memo: "투썸플레이스", amount: 6200),
            Expense(date: date(monthOffset: 0, day: 15), category: food, memo: "점심", amount: 9000),
            Expense(date: date(monthOffset: 0, day: 15), category: cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(monthOffset: 0, day: 15), category: transport, memo: "택시", amount: 12000),
            Expense(date: date(monthOffset: 0, day: 18), category: shopping, memo: "올리브영", amount: 9800),
            Expense(date: date(monthOffset: 0, day: 20), category: food, memo: "저녁", amount: 67000),
            Expense(date: date(monthOffset: 0, day: 22), category: cafe, memo: "카페", amount: 15000),
            Expense(date: date(monthOffset: 0, day: 25), category: shopping, memo: "쿠팡", amount: 120000),
            Expense(date: date(monthOffset: 0, day: 28), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: 0, day: 30), category: food, memo: "외식", amount: 32000),
        ]

        // MARK: - 1달 전
        let oneMonthAgo: [Expense] = [
            Expense(date: date(monthOffset: -1, day: 2), category: food, memo: "김밥천국", amount: 7500),
            Expense(date: date(monthOffset: -1, day: 5), category: cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(monthOffset: -1, day: 9), category: transport, memo: "택시", amount: 11000),
            Expense(date: date(monthOffset: -1, day: 11), category: shopping, memo: "다이소", amount: 13000),
            Expense(date: date(monthOffset: -1, day: 11), category: food, memo: "한식당", amount: 11000),
            Expense(date: date(monthOffset: -1, day: 14), category: cafe, memo: "투썸플레이스", amount: 5800),
            Expense(date: date(monthOffset: -1, day: 16), category: food, memo: "점심", amount: 8500),
            Expense(date: date(monthOffset: -1, day: 18), category: medical, memo: "약국", amount: 7500),
            Expense(date: date(monthOffset: -1, day: 20), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -1, day: 22), category: food, memo: "저녁", amount: 55000),
            Expense(date: date(monthOffset: -1, day: 25), category: cafe, memo: "카페", amount: 14000),
            Expense(date: date(monthOffset: -1, day: 27), category: shopping, memo: "쿠팡", amount: 98000),
            Expense(date: date(monthOffset: -1, day: 29), category: food, memo: "외식", amount: 28000),
        ]

        // MARK: - 2달 전
        let twoMonthsAgo: [Expense] = [
            Expense(date: date(monthOffset: -2, day: 1), category: food, memo: "김밥천국", amount: 8000),
            Expense(date: date(monthOffset: -2, day: 4), category: cafe, memo: "스타벅스", amount: 5500),
            Expense(date: date(monthOffset: -2, day: 7), category: transport, memo: "택시", amount: 13000),
            Expense(date: date(monthOffset: -2, day: 10), category: food, memo: "한식당", amount: 10500),
            Expense(date: date(monthOffset: -2, day: 12), category: shopping, memo: "올리브영", amount: 22000),
            Expense(date: date(monthOffset: -2, day: 15), category: cafe, memo: "투썸플레이스", amount: 6200),
            Expense(date: date(monthOffset: -2, day: 17), category: food, memo: "점심", amount: 9500),
            Expense(date: date(monthOffset: -2, day: 19), category: medical, memo: "병원", amount: 15000),
            Expense(date: date(monthOffset: -2, day: 21), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -2, day: 23), category: food, memo: "저녁", amount: 48000),
            Expense(date: date(monthOffset: -2, day: 26), category: cafe, memo: "카페", amount: 12000),
            Expense(date: date(monthOffset: -2, day: 28), category: shopping, memo: "쿠팡", amount: 75000),
        ]

        // MARK: - 3달 전
        let threeMonthsAgo: [Expense] = [
            Expense(date: date(monthOffset: -3, day: 2), category: food, memo: "김밥천국", amount: 7000),
            Expense(date: date(monthOffset: -3, day: 5), category: cafe, memo: "스타벅스", amount: 6000),
            Expense(date: date(monthOffset: -3, day: 8), category: transport, memo: "택시", amount: 10000),
            Expense(date: date(monthOffset: -3, day: 11), category: food, memo: "한식당", amount: 12000),
            Expense(date: date(monthOffset: -3, day: 13), category: medical, memo: "약국", amount: 8000),
            Expense(date: date(monthOffset: -3, day: 16), category: cafe, memo: "투썸플레이스", amount: 5500),
            Expense(date: date(monthOffset: -3, day: 18), category: shopping, memo: "다이소", amount: 18000),
            Expense(date: date(monthOffset: -3, day: 20), category: food, memo: "점심", amount: 8000),
            Expense(date: date(monthOffset: -3, day: 22), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -3, day: 24), category: food, memo: "저녁", amount: 42000),
            Expense(date: date(monthOffset: -3, day: 27), category: cafe, memo: "카페", amount: 11000),
            Expense(date: date(monthOffset: -3, day: 29), category: shopping, memo: "쿠팡", amount: 65000),
        ]

        // MARK: - 4달 전
        let fourMonthsAgo: [Expense] = [
            Expense(date: date(monthOffset: -4, day: 1), category: food, memo: "김밥천국", amount: 8500),
            Expense(date: date(monthOffset: -4, day: 4), category: cafe, memo: "스타벅스", amount: 5800),
            Expense(date: date(monthOffset: -4, day: 7), category: transport, memo: "택시", amount: 12000),
            Expense(date: date(monthOffset: -4, day: 9), category: food, memo: "한식당", amount: 11500),
            Expense(date: date(monthOffset: -4, day: 12), category: shopping, memo: "올리브영", amount: 19000),
            Expense(date: date(monthOffset: -4, day: 14), category: cafe, memo: "투썸플레이스", amount: 6000),
            Expense(date: date(monthOffset: -4, day: 17), category: food, memo: "점심", amount: 9000),
            Expense(date: date(monthOffset: -4, day: 19), category: medical, memo: "병원", amount: 12000),
            Expense(date: date(monthOffset: -4, day: 21), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -4, day: 23), category: food, memo: "저녁", amount: 51000),
            Expense(date: date(monthOffset: -4, day: 26), category: cafe, memo: "카페", amount: 13000),
            Expense(date: date(monthOffset: -4, day: 28), category: shopping, memo: "쿠팡", amount: 88000),
        ]

        // MARK: - 5달 전
        let fiveMonthsAgo: [Expense] = [
            Expense(date: date(monthOffset: -5, day: 2), category: food, memo: "김밥천국", amount: 7500),
            Expense(date: date(monthOffset: -5, day: 5), category: cafe, memo: "스타벅스", amount: 6200),
            Expense(date: date(monthOffset: -5, day: 8), category: transport, memo: "택시", amount: 11500),
            Expense(date: date(monthOffset: -5, day: 10), category: food, memo: "한식당", amount: 10000),
            Expense(date: date(monthOffset: -5, day: 13), category: shopping, memo: "다이소", amount: 14000),
            Expense(date: date(monthOffset: -5, day: 15), category: cafe, memo: "투썸플레이스", amount: 5500),
            Expense(date: date(monthOffset: -5, day: 18), category: food, memo: "점심", amount: 8500),
            Expense(date: date(monthOffset: -5, day: 20), category: medical, memo: "약국", amount: 9000),
            Expense(date: date(monthOffset: -5, day: 22), category: transport, memo: "지하철", amount: 4500),
            Expense(date: date(monthOffset: -5, day: 24), category: food, memo: "저녁", amount: 45000),
            Expense(date: date(monthOffset: -5, day: 27), category: cafe, memo: "카페", amount: 12500),
            Expense(date: date(monthOffset: -5, day: 29), category: shopping, memo: "쿠팡", amount: 72000),
        ]

        return thisMonth
            + oneMonthAgo
            + twoMonthsAgo
            + threeMonthsAgo
            + fourMonthsAgo
            + fiveMonthsAgo
    }()

    func fetchExpenses(year: Int, month: Int) async -> [Expense] {
        let calendar = Calendar.current
        return expenses.filter {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return y == year && m == month
        }
    }

    func fetchAllExpenses() async -> [Expense] {
        expenses
    }

    func deleteExpense(_ expense: Expense) async {
        expenses.removeAll { $0.id == expense.id }
    }

    func addExpense(_ expense: Expense) async {
        expenses.append(expense)
    }
}
