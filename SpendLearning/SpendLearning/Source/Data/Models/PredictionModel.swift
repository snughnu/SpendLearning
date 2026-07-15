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
    var isSelected: Bool

    init(
        id: String,
        dataCount: Int,
        createdAt: Date,
        isSelected: Bool
    ) {
        self.id = id
        self.dataCount = dataCount
        self.createdAt = createdAt
        self.isSelected = isSelected
    }
}
