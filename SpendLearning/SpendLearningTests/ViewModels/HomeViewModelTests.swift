//
//  HomeViewModelTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/1/26.
//

import Testing

final class StubExpenseUseCase: ExpenseUseCaseProtocol {
    func add(_ expense: Expense) async {}
    func fetch(year: Int, month: Int) async -> [Expense] { [] }
    func delete(_ expense: Expense) async {}
    func deleteAll() async {}
}

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    @Test("1월에서 이전 달로 가면 전년도 12월이 된다")
    func previousMonthFromJanuary() async {
        let sut = HomeViewModel(expenseUseCase: StubExpenseUseCase())
        sut.didSelectYearMonth(year: 2026, month: 1)

        sut.didTapPreviousMonth()

        #expect(sut.currentYear == 2025)
        #expect(sut.currentMonth == 12)
    }

    @Test("12월에서 다음 달로 가면 다음년도 1월이 된다")
    func nextMonthFromDecember() async {
        let sut = HomeViewModel(expenseUseCase: StubExpenseUseCase())
        sut.didSelectYearMonth(year: 2026, month: 12)

        sut.didTapNextMonth()

        #expect(sut.currentYear == 2027)
        #expect(sut.currentMonth == 1)
    }
}
