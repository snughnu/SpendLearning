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
    private(set) var insights: [AIInsightItem] = []
    private(set) var predictionData: [CumulativePrediction] = []
    private(set) var categoryData: [CategoryPredictionDataPoint] = []
    private(set) var today: Int = Calendar.current.component(.day, from: Date())
    private(set) var lastDay: Int = {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())
        return range?.count ?? 30
    }()
    private(set) var isCreatingModel: Bool = false
    private(set) var createModelError: AIModelCreationError? = nil

    private let expenseUseCase: ExpenseUseCaseProtocol
    private let aiUseCase: AIUseCaseProtocol

    var hasPrediction: Bool {
        currentModel != nil
    }

    var sortedInsights: [AIInsightItem] {
        let order: [AIInsightItemType] = [.abnormal, .forecast, .unrecorded]
        return order.map { type in
            insights.first { $0.type == type } ?? AIInsightItem(type: type, description: type.emptyDescription)
        }
    }

    // MARK: - Init
    init(
        expenseUseCase: ExpenseUseCaseProtocol,
        aiUseCase: AIUseCaseProtocol
    ) {
        self.expenseUseCase = expenseUseCase
        self.aiUseCase = aiUseCase
    }

    // MARK: - Input
    func onAppear() async {
        await load()
    }

    func createModel() async {
        isCreatingModel = true
        createModelError = nil

        let result = await aiUseCase.createModel()

        switch result {
        case .success:
            await load()
        case .failure(let error):
            createModelError = error
        }

        isCreatingModel = false
    }

    func selectModel(id: String) async {
        await aiUseCase.selectModel(id: id)
        await load()
    }

    // MARK: - Private
    private func load() async {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())

        async let expenses = expenseUseCase.fetch(year: year, month: month)
        async let currentModel = aiUseCase.fetchCurrentModel()
        async let models = aiUseCase.fetchModels()
        async let insights = aiUseCase.fetchInsights()
        async let dailyPredictions = aiUseCase.fetchDailyPredictions(year: year, month: month)
        async let categoryPredictions = aiUseCase.fetchCategoryPredictions(year: year, month: month)

        let (
            fetchedExpenses,
            fetchedModel,
            fetchedModels,
            fetchedInsights,
            fetchedDaily,
            fetchedCategory
        ) = await (
            expenses,
            currentModel,
            models,
            insights,
            dailyPredictions,
            categoryPredictions
        )

        self.currentModel = fetchedModel
        self.models = fetchedModels
        self.insights = fetchedInsights
        self.predictionData = makeCumulativePrediction(expenses: fetchedExpenses, predictions: fetchedDaily)
        self.categoryData = makeCategoryData(expenses: fetchedExpenses, predictions: fetchedCategory)
    }

    private func makeCumulativePrediction(expenses: [Expense], predictions: [Int: Int]) -> [CumulativePrediction] {
        var cumulativeActual = 0
        var cumulativePredicted = 0

        return (1...lastDay).map { day in
            let daily = expenses
                .filter { Calendar.current.component(.day, from: $0.date) == day }
                .reduce(0) { $0 + $1.amount }

            if day <= today {
                cumulativeActual += daily
            }
            if let predicted = predictions[day] {
                cumulativePredicted += predicted
            }

            return CumulativePrediction(
                day: day,
                actual: day <= today ? cumulativeActual : nil,
                predicted: predictions[day] != nil ? cumulativePredicted : nil
            )
        }
    }

    private func makeCategoryData(expenses: [Expense], predictions: [String: Int]) -> [CategoryPredictionDataPoint] {
        var categoryTotals: [String: Int] = [:]
        for expense in expenses where Calendar.current.component(.day, from: expense.date) <= today {
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
