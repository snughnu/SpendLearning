//
//  AIViewModelTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Testing
import Foundation

@Suite("AIViewModel")
@MainActor
struct AIViewModelTests {

    // MARK: - onAppear / load

    @Test("onAppear 호출 후 predictionData가 채워진다")
    func onAppearFillsPredictionData() async {
        let expenseStub = StubExpenseUseCaseForAI()
        let aiStub = StubAIUseCase()
        aiStub.stubbedDailyPredictions = [1: 10000, 2: 20000]
        let sut = AIViewModel(expenseUseCase: expenseStub, aiUseCase: aiStub)

        await sut.onAppear()

        #expect(sut.predictionData.isEmpty == false)
    }

    @Test("onAppear 호출 후 categoryData가 채워진다")
    func onAppearFillsCategoryData() async {
        let expenseStub = StubExpenseUseCaseForAI()
        let food = Category(name: "식비", emoji: "🍚")
        expenseStub.stubbedExpenses = [
            Expense(date: Date(), category: food, memo: nil, amount: 5000)
        ]
        let aiStub = StubAIUseCase()
        let sut = AIViewModel(expenseUseCase: expenseStub, aiUseCase: aiStub)

        await sut.onAppear()

        #expect(sut.categoryData.isEmpty == false)
        #expect(sut.categoryData.first?.categoryName == "식비")
    }

    // MARK: - hasPrediction

    @Test("예측 데이터가 없으면 hasPrediction이 false다")
    func hasPredictionIsFalseWhenNoPredictions() async {
        let sut = AIViewModel(expenseUseCase: StubExpenseUseCaseForAI(), aiUseCase: StubAIUseCase())

        await sut.onAppear()

        #expect(sut.hasPrediction == false)
    }

    @Test("예측 데이터가 있으면 hasPrediction이 true다")
    func hasPredictionIsTrueWhenPredictionsExist() async {
        let aiStub = StubAIUseCase()
        aiStub.stubbedDailyPredictions = [1: 10000]
        let sut = AIViewModel(expenseUseCase: StubExpenseUseCaseForAI(), aiUseCase: aiStub)

        await sut.onAppear()

        #expect(sut.hasPrediction == true)
    }

    // MARK: - makeCumulativePrediction

    @Test("오늘 날짜에 소비가 없어도 actual이 nil이 아니다")
    func todayActualIsNotNilEvenWithNoExpenses() async {
        let sut = AIViewModel(expenseUseCase: StubExpenseUseCaseForAI(), aiUseCase: StubAIUseCase())

        await sut.onAppear()

        let todayPoint = sut.predictionData.first(where: { $0.day == sut.today })
        #expect(todayPoint?.actual != nil)
    }

    @Test("누적 actual이 올바르게 계산된다")
    func cumulativeActualIsCorrect() async {
        let expenseStub = StubExpenseUseCaseForAI()
        let food = Category(name: "식비", emoji: "🍚")
        let calendar = Calendar.current
        let day1 = calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!
        let day2 = calendar.date(from: DateComponents(year: 2026, month: 7, day: 2))!
        expenseStub.stubbedExpenses = [
            Expense(date: day1, category: food, memo: nil, amount: 1000),
            Expense(date: day2, category: food, memo: nil, amount: 2000),
        ]
        let sut = AIViewModel(expenseUseCase: expenseStub, aiUseCase: StubAIUseCase())

        await sut.onAppear()

        let day2Point = sut.predictionData.first(where: { $0.day == 2 })
        #expect(day2Point?.actual == 3000)
    }

    // MARK: - makeCategoryData

    @Test("categoryData가 actual 기준 내림차순으로 정렬된다")
    func categoryDataIsSortedByActualDescending() async {
        let expenseStub = StubExpenseUseCaseForAI()
        let food = Category(name: "식비", emoji: "🍚")
        let transport = Category(name: "교통", emoji: "🚌")
        let day1 = Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 1))!
        expenseStub.stubbedExpenses = [
            Expense(date: day1, category: transport, memo: nil, amount: 1000),
            Expense(date: day1, category: food, memo: nil, amount: 5000),
        ]
        let sut = AIViewModel(expenseUseCase: expenseStub, aiUseCase: StubAIUseCase())

        await sut.onAppear()

        #expect(sut.categoryData.first?.categoryName == "식비")
        #expect(sut.categoryData.last?.categoryName == "교통")
    }

    // MARK: - sortedInsights

    @Test("sortedInsights가 abnormal, forecast, unrecorded 순서로 정렬된다")
    func sortedInsightsFollowsDefinedOrder() async {
        let aiStub = StubAIUseCase()
        aiStub.stubbedInsights = [
            AIInsightItem(type: .unrecorded, description: "미기록"),
            AIInsightItem(type: .forecast, description: "예고"),
            AIInsightItem(type: .abnormal, description: "이상"),
        ]
        let sut = AIViewModel(expenseUseCase: StubExpenseUseCaseForAI(), aiUseCase: aiStub)

        await sut.onAppear()

        #expect(sut.sortedInsights[0].type == .abnormal)
        #expect(sut.sortedInsights[1].type == .forecast)
        #expect(sut.sortedInsights[2].type == .unrecorded)
    }

    @Test("같은 타입의 인사이트가 여러 개여도 하나만 나온다")
    func sortedInsightsDeduplicatesByType() async {
        let aiStub = StubAIUseCase()
        aiStub.stubbedInsights = [
            AIInsightItem(type: .abnormal, description: "이상1"),
            AIInsightItem(type: .abnormal, description: "이상2"),
        ]
        let sut = AIViewModel(expenseUseCase: StubExpenseUseCaseForAI(), aiUseCase: aiStub)

        await sut.onAppear()

        #expect(sut.sortedInsights.filter { $0.type == .abnormal }.count == 1)
    }
}

// MARK: - Stubs

final class StubExpenseUseCaseForAI: ExpenseUseCaseProtocol {
    var stubbedExpenses: [Expense] = []
    func fetch(year: Int, month: Int) async -> [Expense] { stubbedExpenses }
    func add(_ expense: Expense) async {}
    func delete(_ expense: Expense) async {}
}

final class StubAIUseCase: AIUseCaseProtocol {
    var stubbedModels: [AIModelMetadata] = []
    var stubbedCurrentModel: AIModelMetadata? = nil
    var stubbedInsights: [AIInsightItem] = []
    var stubbedDailyPredictions: [Int: Int] = [:]
    var stubbedCategoryPredictions: [String: Int] = [:]

    func fetchModels() async -> [AIModelMetadata] { stubbedModels }
    func fetchCurrentModel() async -> AIModelMetadata? { stubbedCurrentModel }
    func fetchInsights() async -> [AIInsightItem] { stubbedInsights }
    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] { stubbedDailyPredictions }
    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] { stubbedCategoryPredictions }
}
