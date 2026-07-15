//
//  PredictionModel.swift
//  SpendLearning
//
//  Created by 김성훈 on 7/14/26.
//

import Foundation
import SwiftData

@Model
final class PredictionModel {

    var id: String
    var dataCount: Int
    var createdAt: Date
    private var dailyPredictionsData: Data
    private var categoryPredictionsData: Data

    var dailyPredictions: [Int: Int] {
        (try? JSONDecoder().decode([Int: Int].self, from: dailyPredictionsData)) ?? [:]
    }

    var categoryPredictions: [String: Int] {
        (try? JSONDecoder().decode([String: Int].self, from: categoryPredictionsData)) ?? [:]
    }

    init(
        id: String,
        dataCount: Int,
        createdAt: Date,
        dailyPredictions: [Int: Int],
        categoryPredictions: [String: Int]
    ) {
        self.id = id
        self.dataCount = dataCount
        self.createdAt = createdAt
        self.dailyPredictionsData = (try? JSONEncoder().encode(dailyPredictions)) ?? Data()
        self.categoryPredictionsData = (try? JSONEncoder().encode(categoryPredictions)) ?? Data()
    }

    func update(dataCount: Int, createdAt: Date, dailyPredictions: [Int: Int], categoryPredictions: [String: Int]) {
        self.dataCount = dataCount
        self.createdAt = createdAt
        self.dailyPredictionsData = (try? JSONEncoder().encode(dailyPredictions)) ?? Data()
        self.categoryPredictionsData = (try? JSONEncoder().encode(categoryPredictions)) ?? Data()
    }
}
