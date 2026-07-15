//
//  MockPredictionRepository.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

final class MockPredictionRepository: PredictionRepositoryProtocol {

    private let models: [PredictionModelMetadata] = [
        PredictionModelMetadata(id: "SPa1b2c3", dataCount: 1204, createdAt: Date()),
        PredictionModelMetadata(id: "SPd4e5f6", dataCount: 980,  createdAt: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()),
        PredictionModelMetadata(id: "SPg7h8i9", dataCount: 750,  createdAt: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()),
    ]

    func fetchModels() async -> [PredictionModelMetadata] {
        models
    }

    func fetchCurrentModel() async -> PredictionModelMetadata? {
        models.first
    }

    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int] {
        [
            1: 15000,  2: 18000,  3: 12000,  4: 22000,  5: 19000,
            6: 8000,   7: 25000,  8: 17000,  9: 21000,  10: 14000,
            11: 19000, 12: 23000, 13: 16000, 14: 20000, 15: 18000,
            16: 22000, 17: 15000, 18: 19000, 19: 24000, 20: 17000,
            21: 21000, 22: 18000, 23: 16000, 24: 22000, 25: 20000,
            26: 15000, 27: 19000, 28: 23000, 29: 17000, 30: 21000,
            31: 18000,
        ]
    }

    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int] {
        [
            "식비": 280000,
            "카페/간식": 45000,
            "교통": 60000,
            "쇼핑": 200000,
            "의료/건강": 30000,
        ]
    }

    func createModel(expenses: [Expense]) async -> Result<PredictionModelMetadata, PredictionModelCreationError> {
        let model = PredictionModelMetadata(id: "SPa1b2c3", dataCount: expenses.count, createdAt: Date())
        return .success(model)
    }

    func selectModel(id: String) async {}

    func deleteModel(id: String) async {}
}
