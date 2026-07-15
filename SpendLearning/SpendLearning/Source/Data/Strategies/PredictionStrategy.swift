//
//  PredictionStrategy.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

protocol PredictionStrategy {
    /// 소비 패턴 기반 인사이트 목록
    func predictInsights(expenses: [Expense]) async -> [AIInsightItem]
    /// 일별 예측 지출 금액 [일: 예측금액]
    func predictDaily(expenses: [Expense], year: Int, month: Int) async -> [Int: Int]
    /// 카테고리별 예측 지출 금액 [카테고리명: 예측금액]
    func predictCategory(expenses: [Expense], year: Int, month: Int) async -> [String: Int]
}
