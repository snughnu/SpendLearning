//
//  AIUseCaseTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Testing
import Foundation

@Suite("AIUseCase")
@MainActor
struct AIUseCaseTests {

    @Test("fetchModels 호출 시 Repository의 fetchModels가 호출된다")
    func fetchModelsCallsRepository() async {
        let spy = SpyAIRepository()
        let sut = AIUseCase(repository: spy)

        _ = await sut.fetchModels()

        #expect(spy.fetchModelsCallCount == 1)
    }

    @Test("fetchModels 호출 시 Repository에서 반환한 결과를 그대로 반환한다")
    func fetchModelsReturnsRepositoryResult() async {
        let spy = SpyAIRepository()
        let model = AIModelMetadata(id: "SP260714", dataCount: 1204, accuracy: 82, createdAt: Date())
        spy.stubbedModels = [model]
        let sut = AIUseCase(repository: spy)

        let result = await sut.fetchModels()

        #expect(result.count == 1)
        #expect(result.first?.id == model.id)
    }

    @Test("fetchCurrentModel 호출 시 Repository에서 반환한 결과를 그대로 반환한다")
    func fetchCurrentModelReturnsRepositoryResult() async {
        let spy = SpyAIRepository()
        let model = AIModelMetadata(id: "SP260714", dataCount: 1204, accuracy: 82, createdAt: Date())
        spy.stubbedCurrentModel = model
        let sut = AIUseCase(repository: spy)

        let result = await sut.fetchCurrentModel()

        #expect(result?.id == model.id)
    }

    @Test("fetchDailyPredictions 호출 시 Repository가 올바른 year/month로 호출된다")
    func fetchDailyPredictionsCallsRepositoryWithCorrectYearMonth() async {
        let spy = SpyAIRepository()
        let sut = AIUseCase(repository: spy)

        _ = await sut.fetchDailyPredictions(year: 2026, month: 7)

        #expect(spy.fetchDailyCallCount == 1)
        #expect(spy.fetchedYear == 2026)
        #expect(spy.fetchedMonth == 7)
    }

    @Test("fetchCategoryPredictions 호출 시 Repository가 올바른 year/month로 호출된다")
    func fetchCategoryPredictionsCallsRepositoryWithCorrectYearMonth() async {
        let spy = SpyAIRepository()
        let sut = AIUseCase(repository: spy)

        _ = await sut.fetchCategoryPredictions(year: 2026, month: 7)

        #expect(spy.fetchCategoryCallCount == 1)
        #expect(spy.fetchedYear == 2026)
        #expect(spy.fetchedMonth == 7)
    }

    @Test("fetchInsights 호출 시 Repository에서 반환한 결과를 그대로 반환한다")
    func fetchInsightsReturnsRepositoryResult() async {
        let spy = SpyAIRepository()
        let insight = AIInsightItem(type: .abnormal, description: "테스트")
        spy.stubbedInsights = [insight]
        let sut = AIUseCase(repository: spy)

        let result = await sut.fetchInsights()

        #expect(result.count == 1)
        #expect(result.first?.description == insight.description)
    }
}

// MARK: - Spy

final class SpyAIRepository: AIRepositoryProtocol {
    private(set) var fetchModelsCallCount = 0
    private(set) var fetchCurrentModelCallCount = 0
    private(set) var fetchDailyCallCount = 0
    private(set) var fetchCategoryCallCount = 0
    private(set) var fetchInsightsCallCount = 0
    private(set) var fetchedYear: Int?
    private(set) var fetchedMonth: Int?
    var stubbedModels: [AIModelMetadata] = []
    var stubbedCurrentModel: AIModelMetadata? = nil
    var stubbedInsights: [AIInsightItem] = []

    func fetchModels() async -> [AIModelMetadata] {
        fetchModelsCallCount += 1
        return stubbedModels
    }

    func fetchCurrentModel() async -> AIModelMetadata? {
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

    func fetchInsights() async -> [AIInsightItem] {
        fetchInsightsCallCount += 1
        return stubbedInsights
    }
}
