//
//  PredictionUseCaseProtocol.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

protocol PredictionUseCaseProtocol {
    /// 저장된 모든 예측 모델 메타데이터 목록
    func fetchModels() async -> [PredictionModelMetadata]
    /// 현재 사용 중인 예측 모델 메타데이터
    func fetchCurrentModel() async -> PredictionModelMetadata?
    /// 이번 달 일별 예측 금액 [일: 예측금액]
    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int]
    /// 이번 달 카테고리별 예측 금액 [카테고리명: 예측금액]
    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int]
    /// 예측 모델 생성
    func createModel() async -> Result<PredictionModelMetadata, PredictionModelCreationError>
    /// 예측 모델 선택
    func selectModel(id: String) async
    /// 예측 모델 삭제
    func deleteModel(id: String) async
}
