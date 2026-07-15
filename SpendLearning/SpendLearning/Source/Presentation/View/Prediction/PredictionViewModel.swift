//
//  PredictionViewModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

@Observable
final class PredictionViewModel {

    // MARK: - Output
    private(set) var currentModel: PredictionModelMetadata? = nil
    private(set) var predictionData: [CumulativePrediction] = []
    private(set) var categoryData: [CategoryPrediction] = []
    private(set) var today: Int = Calendar.current.component(.day, from: Date())
    private(set) var lastDay: Int = {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: Date())
        return range?.count ?? 30
    }()
    private(set) var isRecalculating: Bool = false

    private let expenseUseCase: ExpenseUseCaseProtocol
    private let predictionUseCase: PredictionUseCaseProtocol

    var hasPrediction: Bool {
        currentModel != nil
    }

    /// 이번 달 1일~오늘까지의 누적 실제/예측 오차를 바탕으로 산출한 정확도(0~100)
    /// 오차율이 클수록 감소 폭이 완만해지는 지수 감쇠 방식을 사용해, 오차가 100%를 넘어도
    /// 곧바로 0%가 되지 않고 오차 크기에 따라 점진적으로 낮아지도록 한다.
    var accuracy: Float? {
        guard let todayPoint = predictionData.first(where: { $0.day == today }),
              let actual = todayPoint.actual,
              let predicted = todayPoint.predicted,
              actual > 0 else { return nil }

        let errorRatio = abs(Double(predicted) - Double(actual)) / Double(actual)
        return Float(100 * exp(-errorRatio))
    }

    // MARK: - Init
    init(
        expenseUseCase: ExpenseUseCaseProtocol,
        predictionUseCase: PredictionUseCaseProtocol
    ) {
        self.expenseUseCase = expenseUseCase
        self.predictionUseCase = predictionUseCase
    }

    // MARK: - Input
    func onAppear() async {
        await load()
    }

    func recalculate() async {
        isRecalculating = true
        _ = await predictionUseCase.recalculate()
        await load()
        isRecalculating = false
    }

    // MARK: - Private
    private func load() async {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())

        async let expenses = expenseUseCase.fetch(year: year, month: month)
        async let currentModel = predictionUseCase.fetchCurrentModel()

        let (fetchedExpenses, fetchedModel) = await (expenses, currentModel)

        self.currentModel = fetchedModel
        self.predictionData = makeCumulativePrediction(expenses: fetchedExpenses, predictions: fetchedModel?.dailyPredictions ?? [:])
        self.categoryData = makeCategoryData(expenses: fetchedExpenses, predictions: fetchedModel?.categoryPredictions ?? [:], hasModel: fetchedModel != nil)
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

    private func makeCategoryData(expenses: [Expense], predictions: [String: Int], hasModel: Bool) -> [CategoryPrediction] {
        var categoryTotals: [String: Int] = [:]
        for expense in expenses where Calendar.current.component(.day, from: expense.date) <= today {
            categoryTotals[expense.category.name, default: 0] += expense.amount
        }

        let allCategories = Set(categoryTotals.keys).union(Set(predictions.keys))
        return allCategories.map { name in
            // 예측 모델이 있을 때만, 실제 지출이 있는 카테고리는 과거 예측 데이터가 없어도 0원으로 표시한다.
            let predicted = predictions[name] ?? (hasModel && categoryTotals[name] != nil ? 0 : nil)
            return CategoryPrediction(
                categoryName: name,
                actual: categoryTotals[name] ?? 0,
                predicted: predicted
            )
        }
        // 실제 지출도 없고 예측도 0(또는 없음)인 카테고리는 보여줄 정보가 없으므로 제외한다.
        .filter { $0.actual > 0 || ($0.predicted ?? 0) > 0 }
        .sorted { $0.actual > $1.actual }
    }
}
