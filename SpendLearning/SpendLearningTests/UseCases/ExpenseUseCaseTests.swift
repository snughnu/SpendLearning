//
//  ExpenseUseCaseTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Foundation
import Testing

@Suite("ExpenseUseCase")
@MainActor
struct ExpenseUseCaseTests {

    @Test("fetch 호출 시 Repository의 fetchExpenses가 올바른 year/month로 호출된다")
    func fetchCallsRepositoryWithCorrectYearMonth() async {
        let spy = SpyExpenseRepository()
        let sut = ExpenseUseCase(repository: spy)

        _ = await sut.fetch(year: 2026, month: 7)

        #expect(spy.fetchCallCount == 1)
        #expect(spy.fetchedYear == 2026)
        #expect(spy.fetchedMonth == 7)
    }

    @Test("fetch 호출 시 Repository에서 반환한 결과를 그대로 반환한다")
    func fetchReturnsRepositoryResult() async {
        let spy = SpyExpenseRepository()
        let expense = Expense(date: Date(), category: Category(name: "식비", emoji: "🍚"), memo: nil, amount: 5000)
        spy.stubbedExpenses = [expense]
        let sut = ExpenseUseCase(repository: spy)

        let result = await sut.fetch(year: 2026, month: 7)

        #expect(result.count == 1)
        #expect(result.first?.id == expense.id)
    }

    @Test("delete 호출 시 Repository의 deleteExpense가 올바른 Expense로 호출된다")
    func deleteCallsRepositoryWithCorrectExpense() async {
        let spy = SpyExpenseRepository()
        let expense = Expense(date: Date(), category: Category(name: "식비", emoji: "🍚"), memo: nil, amount: 5000)
        let sut = ExpenseUseCase(repository: spy)

        await sut.delete(expense)

        #expect(spy.deleteCallCount == 1)
        #expect(spy.deletedExpense?.id == expense.id)
    }
}

// MARK: - Spy

final class SpyExpenseRepository: ExpenseRepositoryProtocol {
    private(set) var fetchCallCount = 0
    private(set) var fetchedYear: Int?
    private(set) var fetchedMonth: Int?
    private(set) var deleteCallCount = 0
    private(set) var deletedExpense: Expense?
    var stubbedExpenses: [Expense] = []

    func fetchExpenses(year: Int, month: Int) async -> [Expense] {
        fetchCallCount += 1
        fetchedYear = year
        fetchedMonth = month
        return stubbedExpenses
    }

    func fetchAllExpenses() async -> [Expense] {
        return stubbedExpenses
    }

    func addExpense(_ expense: Expense) async {}

    func deleteExpense(_ expense: Expense) async {
        deleteCallCount += 1
        deletedExpense = expense
    }

    func deleteAll() async {}
}
