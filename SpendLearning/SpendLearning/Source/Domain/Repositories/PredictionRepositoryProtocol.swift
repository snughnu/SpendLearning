//
//  PredictionRepositoryProtocol.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

protocol PredictionRepositoryProtocol {
    /// 저장된 예측 모델 메타데이터 (단일)
    func fetchCurrentModel() async -> PredictionModelMetadata?
    /// 현재 지출 데이터로 예측을 다시 계산해 저장한다
    func recalculate(expenses: [Expense]) async -> PredictionModelMetadata
}
