//
//  StatisticsAIRepository.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

final class StatisticsAIRepository: AIRepositoryProtocol {

    private let expenseRepository: ExpenseRepositoryProtocol
    private let strategy = StatisticsPredictionStrategy()

    init(expenseRepository: ExpenseRepositoryProtocol) {
        self.expenseRepository = expenseRepository
    }

    func fetchModels() async -> [AIModelMetadata] {
        let expenses = await expenseRepository.fetchAllExpenses()
        guard let metadata = makeMetadata(expenses: expenses) else { return [] }
        return [metadata]
    }

    func fetchCurrentModel() async -> AIModelMetadata? {
        let expenses = await expenseRepository.fetchAllExpenses()
        return makeMetadata(expenses: expenses)
    }

    func fetchInsights() async -> [AIInsightItem] {
        let expenses = await expenseRepository.fetchAllExpenses()
        guard isSufficientData(expenses: expenses) else { return [] }
        return strategy.predictInsights(expenses: expenses)
    }

    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] {
        let expenses = await expenseRepository.fetchAllExpenses()
        guard isSufficientData(expenses: expenses) else { return [:] }
        return strategy.predictDaily(expenses: expenses, year: year, month: month)
    }

    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] {
        let expenses = await expenseRepository.fetchAllExpenses()
        guard isSufficientData(expenses: expenses) else { return [:] }
        return strategy.predictCategory(expenses: expenses, year: year, month: month)
    }

    // MARK: - Private

    /// 데이터가 예측에 충분한지 확인 (1개월 이상)
    private func isSufficientData(expenses: [Expense]) -> Bool {
        let calendar = Calendar.current
        let months = Set(expenses.map {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return "\(y)-\(m)"
        })
        return months.count >= 1
    }

    /// 소비 데이터 기반으로 모델 메타데이터 생성
    /// 데이터가 부족하면 nil 반환 (currentModel = nil 상태)
    private func makeMetadata(expenses: [Expense]) -> AIModelMetadata? {
        guard isSufficientData(expenses: expenses) else { return nil }

        let calendar = Calendar.current
        let months = Set(expenses.map {
            let y = calendar.component(.year, from: $0.date)
            let m = calendar.component(.month, from: $0.date)
            return "\(y)-\(m)"
        })

        // 데이터 양에 따라 정확도 추정
        // 1개월: 60%, 2개월: 70%, 3개월 이상: 80%
        let accuracy: Float
        switch months.count {
        case 1: accuracy = 60
        case 2: accuracy = 70
        default: accuracy = 80
        }

        return AIModelMetadata(
            id: "SP-STATS",
            dataCount: expenses.count,
            accuracy: accuracy,
            createdAt: Date()
        )
    }
}
