//
//  ExpenseUseCaseTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Testing

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

    func deleteExpense(_ expense: Expense) async {
        deleteCallCount += 1
        deletedExpense = expense
    }
}

// MARK: - Tests

@Suite("ExpenseUseCase")
struct ExpenseUseCaseTests {

    @Test("fetch는 Repository에 올바른 year/month를 전달한다")
    func fetchPassesCorrectYearAndMonth() async {
        let spy = SpyExpenseRepository()
        let sut = ExpenseUseCase(repository: spy)

        _ = await sut.fetch(year: 2026, month: 7)

        #expect(spy.fetchCallCount == 1)
        #expect(spy.fetchedYear == 2026)
        #expect(spy.fetchedMonth == 7)
    }

    @Test("fetch는 Repository가 반환한 목록을 그대로 반환한다")
    func fetchReturnRepositoryResult() async {
        let spy = SpyExpenseRepository()
        let expense = Expense(date: nil, category: .food, memo: "테스트", amount: 1000)
        spy.stubbedExpenses = [expense]
        let sut = ExpenseUseCase(repository: spy)

        let result = await sut.fetch(year: 2026, month: 7)

        #expect(result.count == 1)
        #expect(result.first?.id == expense.id)
    }

    @Test("delete는 Repository에 올바른 Expense를 전달한다")
    func deletePassesCorrectExpense() async {
        let spy = SpyExpenseRepository()
        let expense = Expense(date: nil, category: .cafe, memo: "스타벅스", amount: 6000)
        let sut = ExpenseUseCase(repository: spy)

        await sut.delete(expense)

        #expect(spy.deleteCallCount == 1)
        #expect(spy.deletedExpense?.id == expense.id)
    }
}
