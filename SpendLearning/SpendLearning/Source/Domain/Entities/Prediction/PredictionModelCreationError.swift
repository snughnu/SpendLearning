//
//  PredictionModelCreationError.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

enum PredictionModelCreationError: Error, Equatable {
    /// 저번 달 소비 기록이 없어 모델 생성 불가
    case insufficientData
}
