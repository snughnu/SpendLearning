//
//  PredictionUseCaseTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Testing
import Foundation

@Suite("PredictionUseCase")
@MainActor
struct PredictionUseCaseTests {

    @Test("fetchCurrentModel 호출 시 Repository에서 반환한 결과를 그대로 반환한다")
    func fetchCurrentModelReturnsRepositoryResult() async {
        let spy = SpyPredictionRepository()
        let model = PredictionModelMetadata(id: "SP260714", dataCount: 1204, createdAt: Date(), dailyPredictions: [:], categoryPredictions: [:])
        spy.stubbedCurrentModel = model
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        let result = await sut.fetchCurrentModel()

        #expect(result?.id == model.id)
    }

    @Test("recalculate 호출 시 Repository의 recalculate가 호출된다")
    func recalculateCallsRepository() async {
        let spy = SpyPredictionRepository()
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        _ = await sut.recalculate()

        #expect(spy.recalculateCallCount == 1)
    }

    @Test("recalculate 호출 시 계산된 모델을 반환한다")
    func recalculateReturnsModel() async {
        let spy = SpyPredictionRepository()
        let model = PredictionModelMetadata(id: "SP260714", dataCount: 10, createdAt: Date(), dailyPredictions: [:], categoryPredictions: [:])
        spy.stubbedRecalculateResult = model
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        let result = await sut.recalculate()

        #expect(result.id == "SP260714")
    }
}

// MARK: - Spy

final class SpyPredictionRepository: PredictionRepositoryProtocol {
    private(set) var fetchCurrentModelCallCount = 0
    private(set) var recalculateCallCount = 0

    var stubbedCurrentModel: PredictionModelMetadata? = nil
    var stubbedRecalculateResult = PredictionModelMetadata(id: "SP000000", dataCount: 0, createdAt: Date(), dailyPredictions: [:], categoryPredictions: [:])

    func fetchCurrentModel() async -> PredictionModelMetadata? {
        fetchCurrentModelCallCount += 1
        return stubbedCurrentModel
    }

    func recalculate(expenses: [Expense]) async -> PredictionModelMetadata {
        recalculateCallCount += 1
        return stubbedRecalculateResult
    }
}

// MARK: - Stub

final class StubExpenseRepository: ExpenseRepositoryProtocol {
    func fetchExpenses(year: Int, month: Int) async -> [Expense] { [] }
    func fetchAllExpenses() async -> [Expense] { [] }
    func addExpense(_ expense: Expense) async {}
    func deleteExpense(_ expense: Expense) async {}
}
