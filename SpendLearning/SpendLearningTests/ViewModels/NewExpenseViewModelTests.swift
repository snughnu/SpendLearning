//
//  NewExpenseViewModelTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/2/26.
//

import Testing
import Foundation

final class SpyExpenseUseCase: ExpenseUseCaseProtocol {
    private(set) var addCallCount = 0
    private(set) var addedExpense: Expense?
    private(set) var deleteCallCount = 0
    private(set) var deletedExpense: Expense?

    func fetch(year: Int, month: Int) async -> [Expense] { [] }
    func add(_ expense: Expense) async { addCallCount += 1; addedExpense = expense }
    func delete(_ expense: Expense) async { deleteCallCount += 1; deletedExpense = expense }
}

final class StubCategoryUseCaseForNewExpense: CategoryUseCaseProtocol {
    var stubbedCategories: [Category] = []
    var shouldThrow = false

    func fetchCategories() async throws -> [Category] {
        if shouldThrow { throw StubError.generic }
        return stubbedCategories
    }

    func addCategory(name: String, emoji: String) async throws {}
    func updateCategory(_ category: Category, name: String, emoji: String) async throws {}
    func deleteCategory(_ category: Category) async throws {}
    func resetToDefault() async throws {}
    func reorderCategories(_ categories: [Category]) async throws {}
}

@Suite("NewExpenseViewModel")
@MainActor
struct NewExpenseViewModelTests {

    @Test("추가 모드에서 저장 시 add만 호출된다")
    func saveInAddMode() async {
        let spy = SpyExpenseUseCase()
        let sut = NewExpenseViewModel(
            expenseUseCase: spy,
            categoryUseCase: StubCategoryUseCaseForNewExpense(),
            date: Date()
        )
        sut.didSelectCategory(Category(name: "식비", emoji: "🍚"))

        await sut.didSaveExpense()

        #expect(spy.addCallCount == 1)
        #expect(spy.deleteCallCount == 0)
    }

    @Test("수정 모드에서 저장 시 delete 후 add가 호출된다")
    func saveInEditMode() async {
        let spy = SpyExpenseUseCase()
        let food = Category(name: "식비", emoji: "🍚")
        let editing = Expense(date: Date(), category: food, memo: nil, amount: 5000)
        let sut = NewExpenseViewModel(
            expenseUseCase: spy,
            categoryUseCase: StubCategoryUseCaseForNewExpense(),
            date: Date(),
            editingExpense: editing
        )
        sut.didSelectCategory(Category(name: "카페", emoji: "☕️"))

        await sut.didSaveExpense()

        #expect(spy.deleteCallCount == 1)
        #expect(spy.deletedExpense?.id == editing.id)
        #expect(spy.addCallCount == 1)
    }

    @Test("수정 모드에서 initialAmount와 initialMemo가 기존 값으로 반환된다")
    func initialValuesInEditMode() {
        let food = Category(name: "식비", emoji: "🍚")
        let editing = Expense(date: Date(), category: food, memo: "점심", amount: 12000)
        let sut = NewExpenseViewModel(
            expenseUseCase: SpyExpenseUseCase(),
            categoryUseCase: StubCategoryUseCaseForNewExpense(),
            date: Date(),
            editingExpense: editing
        )

        #expect(sut.initialAmount == 12000)
        #expect(sut.initialMemo == "점심")
    }

    @Test("fetchCategories 실패 시 fetchError가 설정된다")
    func loadCategoriesSetsErrorOnFailure() async {
        let stub = StubCategoryUseCaseForNewExpense()
        stub.shouldThrow = true
        let sut = NewExpenseViewModel(
            expenseUseCase: SpyExpenseUseCase(),
            categoryUseCase: stub,
            date: Date()
        )

        await sut.loadCategories()

        #expect(sut.fetchError != nil)
    }
}
