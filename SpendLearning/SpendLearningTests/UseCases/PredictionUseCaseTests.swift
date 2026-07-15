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

    @Test("fetchModels 호출 시 Repository의 fetchModels가 호출된다")
    func fetchModelsCallsRepository() async {
        let spy = SpyPredictionRepository()
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        _ = await sut.fetchModels()

        #expect(spy.fetchModelsCallCount == 1)
    }

    @Test("fetchModels 호출 시 Repository에서 반환한 결과를 그대로 반환한다")
    func fetchModelsReturnsRepositoryResult() async {
        let spy = SpyPredictionRepository()
        let model = PredictionModelMetadata(id: "SP260714", dataCount: 1204, createdAt: Date())
        spy.stubbedModels = [model]
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        let result = await sut.fetchModels()

        #expect(result.count == 1)
        #expect(result.first?.id == model.id)
    }

    @Test("fetchCurrentModel 호출 시 Repository에서 반환한 결과를 그대로 반환한다")
    func fetchCurrentModelReturnsRepositoryResult() async {
        let spy = SpyPredictionRepository()
        let model = PredictionModelMetadata(id: "SP260714", dataCount: 1204, createdAt: Date())
        spy.stubbedCurrentModel = model
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        let result = await sut.fetchCurrentModel()

        #expect(result?.id == model.id)
    }

    @Test("fetchDailyPredictions 호출 시 Repository가 올바른 year/month로 호출된다")
    func fetchDailyPredictionsCallsRepositoryWithCorrectYearMonth() async {
        let spy = SpyPredictionRepository()
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        _ = await sut.fetchDailyPredictions(year: 2026, month: 7)

        #expect(spy.fetchDailyCallCount == 1)
        #expect(spy.fetchedYear == 2026)
        #expect(spy.fetchedMonth == 7)
    }

    @Test("fetchCategoryPredictions 호출 시 Repository가 올바른 year/month로 호출된다")
    func fetchCategoryPredictionsCallsRepositoryWithCorrectYearMonth() async {
        let spy = SpyPredictionRepository()
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        _ = await sut.fetchCategoryPredictions(year: 2026, month: 7)

        #expect(spy.fetchCategoryCallCount == 1)
        #expect(spy.fetchedYear == 2026)
        #expect(spy.fetchedMonth == 7)
    }

    @Test("createModel 호출 시 Repository의 createModel이 호출된다")
    func createModelCallsRepository() async {
        let spy = SpyPredictionRepository()
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        _ = await sut.createModel()

        #expect(spy.createModelCallCount == 1)
    }

    @Test("createModel 성공 시 생성된 모델을 반환한다")
    func createModelReturnsModelOnSuccess() async {
        let spy = SpyPredictionRepository()
        let model = PredictionModelMetadata(id: "SP260714", dataCount: 10, createdAt: Date())
        spy.stubbedCreateModelResult = .success(model)
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        let result = await sut.createModel()

        if case .success(let created) = result {
            #expect(created.id == "SP260714")
        } else {
            Issue.record("성공을 기대했지만 실패 반환")
        }
    }

    @Test("createModel 실패 시 insufficientData 에러를 반환한다")
    func createModelReturnsErrorOnInsufficientData() async {
        let spy = SpyPredictionRepository()
        spy.stubbedCreateModelResult = .failure(.insufficientData)
        let sut = PredictionUseCase(repository: spy, expenseRepository: StubExpenseRepository())

        let result = await sut.createModel()

        if case .failure(let error) = result {
            #expect(error == .insufficientData)
        } else {
            Issue.record("실패를 기대했지만 성공 반환")
        }
    }
}

// MARK: - Spy

final class SpyPredictionRepository: PredictionRepositoryProtocol {
    private(set) var fetchModelsCallCount = 0
    private(set) var fetchCurrentModelCallCount = 0
    private(set) var fetchDailyCallCount = 0
    private(set) var fetchCategoryCallCount = 0
    private(set) var fetchedYear: Int?
    private(set) var fetchedMonth: Int?
    private(set) var createModelCallCount = 0
    private(set) var deleteModelCallCount = 0
    private(set) var deletedId: String?

    var stubbedModels: [PredictionModelMetadata] = []
    var stubbedCurrentModel: PredictionModelMetadata? = nil
    var stubbedCreateModelResult: Result<PredictionModelMetadata, PredictionModelCreationError> = .failure(.insufficientData)

    func fetchModels() async -> [PredictionModelMetadata] {
        fetchModelsCallCount += 1
        return stubbedModels
    }

    func fetchCurrentModel() async -> PredictionModelMetadata? {
        fetchCurrentModelCallCount += 1
        return stubbedCurrentModel
    }

    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] {
        fetchDailyCallCount += 1
        fetchedYear = year
        fetchedMonth = month
        return [:]
    }

    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] {
        fetchCategoryCallCount += 1
        fetchedYear = year
        fetchedMonth = month
        return [:]
    }

    func createModel(expenses: [Expense]) async -> Result<PredictionModelMetadata, PredictionModelCreationError> {
        createModelCallCount += 1
        return stubbedCreateModelResult
    }

    func selectModel(id: String) async {}

    func deleteModel(id: String) async {
        deleteModelCallCount += 1
        deletedId = id
    }
}

// MARK: - Stub

final class StubExpenseRepository: ExpenseRepositoryProtocol {
    func fetchExpenses(year: Int, month: Int) async -> [Expense] { [] }
    func fetchAllExpenses() async -> [Expense] { [] }
    func addExpense(_ expense: Expense) async {}
    func deleteExpense(_ expense: Expense) async {}
}
