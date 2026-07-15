//
//  PredictionViewModelTests.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Testing
import Foundation

@Suite("PredictionViewModel")
@MainActor
struct PredictionViewModelTests {

    // MARK: - onAppear / load

    @Test("onAppear 호출 후 predictionData가 채워진다")
    func onAppearFillsPredictionData() async {
        let expenseStub = StubExpenseUseCaseForPrediction()
        let predictionStub = StubPredictionUseCase()
        predictionStub.stubbedDailyPredictions = [1: 10000, 2: 20000]
        let sut = PredictionViewModel(expenseUseCase: expenseStub, predictionUseCase: predictionStub)

        await sut.onAppear()

        #expect(sut.predictionData.isEmpty == false)
    }

    @Test("onAppear 호출 후 categoryData가 채워진다")
    func onAppearFillsCategoryData() async {
        let expenseStub = StubExpenseUseCaseForPrediction()
        let food = Category(name: "식비", emoji: "🍚")
        expenseStub.stubbedExpenses = [
            Expense(date: Date(), category: food, memo: nil, amount: 5000)
        ]
        let predictionStub = StubPredictionUseCase()
        let sut = PredictionViewModel(expenseUseCase: expenseStub, predictionUseCase: predictionStub)

        await sut.onAppear()

        #expect(sut.categoryData.isEmpty == false)
        #expect(sut.categoryData.first?.categoryName == "식비")
    }

    // MARK: - hasPrediction

    @Test("예측 데이터가 없으면 hasPrediction이 false다")
    func hasPredictionIsFalseWhenNoPredictions() async {
        let sut = PredictionViewModel(expenseUseCase: StubExpenseUseCaseForPrediction(), predictionUseCase: StubPredictionUseCase())

        await sut.onAppear()

        #expect(sut.hasPrediction == false)
    }

    @Test("예측 데이터가 있으면 hasPrediction이 true다")
    func hasPredictionIsTrueWhenPredictionsExist() async {
        let predictionStub = StubPredictionUseCase()
        predictionStub.stubbedCurrentModel = PredictionModelMetadata(id: "SPa1b2c3", dataCount: 10, createdAt: Date())
        let sut = PredictionViewModel(expenseUseCase: StubExpenseUseCaseForPrediction(), predictionUseCase: predictionStub)

        await sut.onAppear()

        #expect(sut.hasPrediction == true)
    }

    // MARK: - makeCumulativePrediction

    @Test("오늘 날짜에 소비가 없어도 actual이 nil이 아니다")
    func todayActualIsNotNilEvenWithNoExpenses() async {
        let sut = PredictionViewModel(expenseUseCase: StubExpenseUseCaseForPrediction(), predictionUseCase: StubPredictionUseCase())

        await sut.onAppear()

        let todayPoint = sut.predictionData.first(where: { $0.day == sut.today })
        #expect(todayPoint?.actual != nil)
    }

    @Test("누적 actual이 올바르게 계산된다")
    func cumulativeActualIsCorrect() async {
        let expenseStub = StubExpenseUseCaseForPrediction()
        let food = Category(name: "식비", emoji: "🍚")
        let calendar = Calendar.current
        let day1 = calendar.date(from: DateComponents(year: 2026, month: 7, day: 1))!
        let day2 = calendar.date(from: DateComponents(year: 2026, month: 7, day: 2))!
        expenseStub.stubbedExpenses = [
            Expense(date: day1, category: food, memo: nil, amount: 1000),
            Expense(date: day2, category: food, memo: nil, amount: 2000),
        ]
        let sut = PredictionViewModel(expenseUseCase: expenseStub, predictionUseCase: StubPredictionUseCase())

        await sut.onAppear()

        let day2Point = sut.predictionData.first(where: { $0.day == 2 })
        #expect(day2Point?.actual == 3000)
    }

    // MARK: - makeCategoryData

    @Test("categoryData가 actual 기준 내림차순으로 정렬된다")
    func categoryDataIsSortedByActualDescending() async {
        let expenseStub = StubExpenseUseCaseForPrediction()
        let food = Category(name: "식비", emoji: "🍚")
        let transport = Category(name: "교통", emoji: "🚌")
        let day1 = Calendar.current.date(from: DateComponents(year: 2026, month: 7, day: 1))!
        expenseStub.stubbedExpenses = [
            Expense(date: day1, category: transport, memo: nil, amount: 1000),
            Expense(date: day1, category: food, memo: nil, amount: 5000),
        ]
        let sut = PredictionViewModel(expenseUseCase: expenseStub, predictionUseCase: StubPredictionUseCase())

        await sut.onAppear()

        #expect(sut.categoryData.first?.categoryName == "식비")
        #expect(sut.categoryData.last?.categoryName == "교통")
    }

}

// MARK: - Stubs

final class StubExpenseUseCaseForPrediction: ExpenseUseCaseProtocol {
    var stubbedExpenses: [Expense] = []
    func fetch(year: Int, month: Int) async -> [Expense] { stubbedExpenses }
    func add(_ expense: Expense) async {}
    func delete(_ expense: Expense) async {}
}

final class StubPredictionUseCase: PredictionUseCaseProtocol {
    var stubbedModels: [PredictionModelMetadata] = []
    var stubbedCurrentModel: PredictionModelMetadata? = nil
    var stubbedDailyPredictions: [Int: Int] = [:]
    var stubbedCategoryPredictions: [String: Int] = [:]
    var stubbedCreateModelResult: Result<PredictionModelMetadata, PredictionModelCreationError> = .failure(.insufficientData)

    func fetchModels() async -> [PredictionModelMetadata] { stubbedModels }
    func fetchCurrentModel() async -> PredictionModelMetadata? { stubbedCurrentModel }
    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] { stubbedDailyPredictions }
    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] { stubbedCategoryPredictions }
    func createModel() async -> Result<PredictionModelMetadata, PredictionModelCreationError> { stubbedCreateModelResult }
    func selectModel(id: String) async {}
    func deleteModel(id: String) async {}
}
