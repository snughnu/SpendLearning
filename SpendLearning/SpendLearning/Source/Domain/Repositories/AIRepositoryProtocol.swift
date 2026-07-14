//
//  AIRepositoryProtocol.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

protocol AIRepositoryProtocol {
    /// 저장된 모든 AI 모델 메타데이터 목록
    func fetchModels() async -> [AIModelMetadata]
    /// 현재 사용 중인 AI 모델 메타데이터
    func fetchCurrentModel() async -> AIModelMetadata?
    /// 이번 달 인사이트 목록
    func fetchInsights() async -> [AIInsightItem]
    /// 이번 달 일별 예측 금액 [일: 예측금액]
    func fetchDailyPredictions(year: Int, month: Int) async -> [Int: Int]
    /// 이번 달 카테고리별 예측 금액 [카테고리명: 예측금액]
    func fetchCategoryPredictions(year: Int, month: Int) async -> [String: Int]
}
