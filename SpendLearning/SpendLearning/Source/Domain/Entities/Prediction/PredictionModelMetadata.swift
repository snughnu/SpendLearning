//
//  PredictionModelMetadata.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation

struct PredictionModelMetadata {
    let id: String
    let dataCount: Int
    let createdAt: Date
    let dailyPredictions: [Int: Int]
    let categoryPredictions: [String: Int]
}
