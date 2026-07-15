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

    @Test("recalculate 성공 시 계산된 모델을 반환한다")
    func recalculateReturnsModelOnSuccess() async {
        let spy = SpyPredictionRepository()
        let model = PredictionModelMetadata(id: "SP260714", dataCount: 10, createdAt: Date(), dailyPredictions: [:], categoryPredictions: [:])
        spy.stubbedRecalculateResult = .success(model)
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        let result = await sut.recalculate()

        if case .success(let created) = result {
            #expect(created.id == "SP260714")
        } else {
            Issue.record("성공을 기대했지만 실패 반환")
        }
    }

    @Test("recalculate 실패 시 insufficientData 에러를 반환한다")
    func recalculateReturnsErrorOnInsufficientData() async {
        let spy = SpyPredictionRepository()
        spy.stubbedRecalculateResult = .failure(.insufficientData)
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        let result = await sut.recalculate()

        if case .failure(let error) = result {
            #expect(error == .insufficientData)
        } else {
            Issue.record("실패를 기대했지만 성공 반환")
        }
    }
}

// MARK: - Spy

final class SpyPredictionRepository: PredictionRepositoryProtocol {
    private(set) var fetchCurrentModelCallCount = 0
    private(set) var recalculateCallCount = 0

    var stubbedCurrentModel: PredictionModelMetadata? = nil
    var stubbedRecalculateResult: Result<PredictionModelMetadata, PredictionModelCreationError> = .failure(.insufficientData)

    func fetchCurrentModel() async -> PredictionModelMetadata? {
        fetchCurrentModelCallCount += 1
        return stubbedCurrentModel
    }

    func recalculate(expenses: [Expense]) async -> Result<PredictionModelMetadata, PredictionModelCreationError> {
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
