//
//  AIUseCase.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

final class AIUseCase: AIUseCaseProtocol {

    private let repository: AIRepositoryProtocol

    init(repository: AIRepositoryProtocol) {
        self.repository = repository
    }

    func fetchModels() async -> [AIModelMetadata] {
        await repository.fetchModels()
    }

    func fetchCurrentModel() async -> AIModelMetadata? {
        await repository.fetchCurrentModel()
    }

    func fetchInsights() async -> [AIInsightItemData] {
        await repository.fetchInsights()
    }

    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] {
        await repository.fetchDailyPredictions(year: year, month: month)
    }

    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] {
        await repository.fetchCategoryPredictions(year: year, month: month)
    }
}
