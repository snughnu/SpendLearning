//
//  AIViewModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

@Observable
final class AIViewModel {

    // MARK: - Output
    private(set) var currentModel: AIModelMetadata? = nil
    private(set) var models: [AIModelMetadata] = []
    private(set) var predictionData: [PredictionDataPoint] = []
    private(set) var categoryData: [CategoryPredictionDataPoint] = []
    private(set) var today: Int = Calendar.current.component(.day, from: Date())
    private(set) var lastDay: Int = {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())
        return range?.count ?? 30
    }()

    private let expenseUseCase: ExpenseUseCaseProtocol
    private let aiUseCase: AIUseCaseProtocol

    // MARK: - Init
    init(
        expenseUseCase: ExpenseUseCaseProtocol,
        aiUseCase: AIUseCaseProtocol
    ) {
        self.expenseUseCase = expenseUseCase
        self.aiUseCase = aiUseCase
    }

    // MARK: - Input
    func onAppear() {
        Task {
            await load()
        }
    }

    // MARK: - Private
    private func load() async {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())

        async let expenses = expenseUseCase.fetch(year: year, month: month)
        async let currentModel = aiUseCase.fetchCurrentModel()
        async let models = aiUseCase.fetchModels()
        async let dailyPredictions = aiUseCase.fetchDailyPredictions(year: year, month: month)
        async let categoryPredictions = aiUseCase.fetchCategoryPredictions(year: year, month: month)

        let (
            fetchedExpenses,
            fetchedModel,
            fetchedModels,
            fetchedDaily,
            fetchedCategory
        ) = await (
            expenses,
            currentModel,
            models,
            dailyPredictions,
            categoryPredictions
        )

        self.currentModel = fetchedModel
        self.models = fetchedModels
        self.predictionData = makePredictionData(expenses: fetchedExpenses, predictions: fetchedDaily)
        self.categoryData = makeCategoryData(expenses: fetchedExpenses, predictions: fetchedCategory)
    }

    private func makePredictionData(expenses: [Expense], predictions: [Int: Int]) -> [PredictionDataPoint] {
        (1...lastDay).map { day in
            let actual = expenses
                .filter { Calendar.current.component(.day, from: $0.date) == day }
                .reduce(0) { $0 + $1.amount }
            return PredictionDataPoint(
                day: day,
                actual: actual > 0 ? actual : (day <= today ? actual : nil),
                predicted: predictions[day]
            )
        }
    }

    private func makeCategoryData(expenses: [Expense], predictions: [String: Int]) -> [CategoryPredictionDataPoint] {
        var categoryTotals: [String: Int] = [:]
        for expense in expenses {
            categoryTotals[expense.category.name, default: 0] += expense.amount
        }

        let allCategories = Set(categoryTotals.keys).union(Set(predictions.keys))
        return allCategories.map { name in
            CategoryPredictionDataPoint(
                categoryName: name,
                actual: categoryTotals[name] ?? 0,
                predicted: predictions[name]
            )
        }
        .sorted { $0.actual > $1.actual }
    }
}
