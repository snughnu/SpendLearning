//
//  PredictionStrategy.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

protocol PredictionStrategy {
    /// 일별 예측 지출 금액 [일: 예측금액]
    func predictDaily(expenses: [Expense], year: Int, month: Int) async -> [Int: Int]
    /// 카테고리별 예측 지출 금액 [카테고리명: 예측금액]
    func predictCategory(expenses: [Expense], year: Int, month: Int) async -> [String: Int]
}
